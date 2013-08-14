package Munge::Controller::Feed;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account synchronize_feed feed_view|;
use Munge::Model::Account;
use Munge::Model::Feed;
use Munge::Model::FeedItem;
use Munge::Model::Feed::ItemCollection;
use Munge::Model::View::Feed;
use Munge::Model::View::FeedItem;
use Munge::Types qw|UUID|;
use Munge::Util qw|proc_fork|;

prefix '/feed';

get '/' => sub {
    my $feed_view = feed_view();

    my $subscriptions = $feed_view->all_feeds;
    my $item_list_view = feed_item_view( undef, scalar( @{$subscriptions} ) );

    return template 'feed/index',
      {
        feeds => $subscriptions,
        items => $item_list_view,
      };

};

get '/subscribe/:feed' => sub {
    my $feed_id = param('feed');

    my $feed_uuid = to_UUID($feed_id);

    redirect('/') if not $feed_uuid;

    my $subscription =
      Munge::Model::AccountFeed->subscribe_feed( account(), $feed_uuid );

    redirect( '/feed/' . $feed_id );
};

get '/refresh/:feed' => sub {
    my $feed_id = param('feed');

    # todo 404
    redirect('/') if not to_UUID($feed_id);

    my $feed = Munge::Model::Feed->load( to_UUID($feed_id) );

    proc_fork(
        sub {
            synchronize_feed($feed);
            return;
        }
    );

    return redirect(qq|/feed/read/$feed_id|);
};

get '/all/read/:feed' => sub {
    my $feed_id = param('feed');

    # todo 404
    redirect('/') if not to_UUID($feed_id);

    my $account = account();
    my $feed    = Munge::Model::Feed->load( to_UUID($feed_id) );

    my $collection = Munge::Model::Feed::ItemCollection->new(
        feed    => $feed,
        account => $account
    );

    $collection->read(1);

    return redirect(qq|/feed/read/$feed_id|);
};

get '/remove/:feed' => sub {
    my $uuid = to_UUID( param('feed') );

    return status('not_found') if not $uuid;

    Munge::Model::AccountFeed->unsubscribe_feed( account(), $uuid );

    return redirect('/feed/');
};

get '/read/:feed' => sub {
    my $feed_id   = param('feed');
    my $feed_uuid = to_UUID($feed_id);

    return status('not_found') if not $feed_uuid;

    my $feed           = Munge::Model::Feed->load($feed_uuid);
    my $feed_view      = Munge::Model::View::Feed->new( account => account() );
    my $all_feeds_list = $feed_view->all_feeds;

    my $item_list_view =
      feed_item_view( $feed_id, scalar( @{$all_feeds_list} ) );

    my $template = _get_template($feed_id);

    return template "feed/$template",
      {
        feed => {
            title       => $feed->title,
            description => $feed->description,
            uuid_string => $feed_id,
        },
        feeds => $all_feeds_list,
        items => $item_list_view || undef,
      };

};

get '/starred' => sub {
    return special_view('starred');
};

sub special_view {
    my ($action) = @_;

    my $template      = _get_template($action);
    my $feed_view     = Munge::Model::View::Feed->new( account => account() );
    my $subscriptions = $feed_view->all_feeds;

    return template "feed/$template",
      {
        feed => {
            title       => ucfirst($action),
            description => 'Unread posts',
            uuid_string => $action,
        },
        feeds => $subscriptions,
        items => feed_item_view( $action, scalar( @{$subscriptions} ) )
          || undef,
      };
}

sub _get_feed_info {
    my ( $feed_id, $item_list_view ) = @_;

    my $feed_info;

    if ( $feed_id and to_UUID($feed_id) ) {
        $feed_info = {
            title       => $item_list_view->[0]->{feed_title},
            description => $item_list_view->[0]->{feed_description},
            uuid_string => $item_list_view->[0]->{feed_uuid_string},
        };
    }
    else {
        $feed_info =
          { title => ucfirst($feed_id), description => 'Unread posts' };
    }

    return $feed_info;
}

sub _get_template {
    my ($feed_id) = @_;

    return 'index'  if not $feed_id;
    return 'crunge' if $feed_id eq 'archive';
    return 'saved'  if $feed_id eq 'starred';
    return 'index';
}

sub feed_item_view {
    my ( $feed_id, $subscription_count ) = @_;

    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    return $view->unread()                  if not $feed_id;
    return $view->no_subscriptions()        if $subscription_count == 0;
    return $view->starred()                 if $feed_id eq 'starred';
    return $view->list( to_UUID($feed_id) ) if to_UUID($feed_id);
    return;
}

true;
