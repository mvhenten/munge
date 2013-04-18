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

    return template 'feed/index',
      {
        feeds => $feed_view->all_feeds,
        items => feed_item_view(),
      };

};

get '/refresh/:feed' => sub {
    my $feed_id = param('feed');

    # todo 404
    redirect('/') if not to_UUID($feed_id);

    my $feed = Munge::Model::Feed->load( to_UUID($feed_id), account() );

    proc_fork(
        sub {
            synchronize_feed($feed);
            return;
        }
    );

    return redirect(qq|/feed/$feed_id|);
};

get '/read/:feed' => sub {
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

    return redirect(qq|/feed/$feed_id|);
};

get '/remove/:feed' => sub {
    my $feed_id = param('feed');

    # todo 404
    redirect('/') if not to_UUID($feed_id);

    my $account = account();
    my $feed = Munge::Model::Feed->load( to_UUID($feed_id), $account );

    $feed->delete();

    return redirect('/feed/');
};

get '/refresh' => sub {
    my $account = account();

    redirect('/') if session('refresh_lock');

    debug('reloading feeds');

    # todo logging
    session( 'refresh_lock', 1 );

    proc_fork(
        sub {
            my @feeds = reverse $account->feeds;
            foreach my $feed_rs (@feeds) {
                my $feed = Munge::Model::Feed->load( $feed_rs->uuid, $account );
                synchronize_feed($feed);
            }

            session( 'refresh_lock', 0 );

        }
    );

    return redirect('/');
};

get '/:feed' => sub {
    my $feed_id   = param('feed');
    my $account   = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    my $feed_info;
    my $item_list_view = feed_item_view($feed_id);

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

    my $template = _get_template($feed_id);

    return template "feed/$template",
      {
        feed  => $feed_info,
        feeds => $feed_view->all_feeds,
        items => $item_list_view || undef,
      };

};

sub _get_template {
    my ($feed_id) = @_;

    return 'index'  if not $feed_id;
    return 'crunge' if $feed_id eq 'archive';
    return 'saved'  if $feed_id eq 'starred';
    return 'index';
}

sub feed_item_view {
    my ($feed_id) = @_;

    $feed_id ||= 'today';

    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    return $view->today()   if $feed_id eq 'today';
    return $view->crunch()  if $feed_id eq 'archive';
    return $view->starred() if $feed_id eq 'starred';
    return $view->list( to_UUID($feed_id) ) if to_UUID($feed_id);
    return;
}

true;
