Munge::Controller::REST::Feed;

use strict;
use warnings;
use Data::Dumper;

use Dancer ':syntax';
use Dancer::Plugin::REST;

use Munge::Helper qw|account synchronize_feed feed_view feed_item_view|;
use Munge::Model::View::Feed;
use Munge::Model::View::FeedItem;

set serializer => 'JSON';

sub API_PREFIX {
    return '/API/v1/feed';
}

prefix API_PREFIX();

#feed            | get todays feed list    | ...                 | subscribe             | ...
#feed/<id>       | display feed            | mark read           | ...                   | unsubscribe
#feed/archive    | collection unread items | ...                 | mark item unread      | clear all unread
#feed/starred    | collection saved items  | remove starred item | create new starred    | clear collection

# get todays feed list
get '/' => sub {
    my $feed_view     = feed_view();
    my $subscriptions = $feed_view->all_feeds;

    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    my $feed_items;

    if ( scalar( @{$subscriptions} ) == 0 ) {
        $feed_items = $view->no_subscriptions();
    }
    else {
        $feed_items = _get_feed_item_view( 'today', $view );
    }

    return status_ok(
        {
            subscriptions => $subscriptions,
            items         => $feed_items
        }
    );
};

# subscribe to a new feed
post '/' => sub {
    my $url = param('feed_url');

    if ( my $uri = is_url($url) ) {
        my $subscription =
          Munge::Model::AccountFeed->subscribe( account(), $uri );

        synchronize_feed( $subscription->feed );

        return status_created(
            {
                location => API_PREFIX() . '/'
                  . uuid_string( $subscription->feed->uuid )
            }
        );
    }
    return status_bad_request('feed_url is not a valid url');
};

get '/archive' => sub {
    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    my $feed_items = _get_feed_item_view( 'archive', $view );

    return status_ok( { items => $feed_items } );
};

post '/archive' => sub {
    my $afi = get_account_feed_item( param('feed_item_uuid') );

    return status_bad_request( 'cannot load feed' ) if not $afi;

    $afi->set_unread();
    $afi->store();
    
    return status_created( location => API_PREFIX . '/' . uuid_string( $afi->feed_item_uuid ) );
};

delete '/archive' => sub {
    return status_not_found('Not implemented yet');
};

get '/starred' => sub {
    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    my $feed_items = _get_feed_item_view( 'starred', $view );

    return status_ok( { items => $feed_items } );
};

put '/starred' => sub {
    my $afi = get_account_feed_item( param('feed_item_uuid') );

    return status_bad_request( 'cannot load feed' ) if not $afi;

    $afi->unset_star();
    $afi->store();
    
    return status_ok();
};

post '/starred' => sub {
    my $afi = get_account_feed_item( param('feed_item_uuid') );

    return status_bad_request( 'cannot load feed' ) if not $afi;

    $afi->set_star();
    $afi->store();
    
    return status_created( location => API_PREFIX . '/' . uuid_string( $afi->feed_item_uuid ) );
};

delete '/starred' => sub {

};

get '/:fid' => sub {

};

put '/:fid' => sub {

};

delete '/:fid' => sub {

};

sub _get_feed_item_view {
    my ( $view_id, $view ) = @_;

    return $view->today()   if $view_id eq 'today';
    return $view->crunch()  if $view_id eq 'archive';
    return $view->starred() if $view_id eq 'starred';
    return $view->list( to_UUID($view_id) ) if to_UUID($view_id);

    Carp::confess("invalid feed_id: $view_id");
}

