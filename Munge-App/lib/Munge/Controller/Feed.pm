package Munge::Controller::Feed;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Model::Account;
use Munge::Model::Feed;
use Munge::Model::FeedItem;
use Munge::Model::View::FeedItem;
use Munge::Model::View::Feed;
use Munge::Types qw|UUID|;
use Proc::Fork;
use Try::Tiny;

prefix undef;

sub account {
    my $account = Munge::Model::Account->new()->find( session('account') );
    return $account;
}

get '/' => sub {
    my $account = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    template 'feed/index',
      {
        feeds => $feed_view->all_feeds,
        items => feed_item_view(),
      };

};

get '/feed/refresh/:feed' => sub {
    my $feed_id = param('feed');

    # todo 404
    redirect('/') if not to_UUID($feed_id);

    my $account = account();
    my $feed = Munge::Model::Feed->load( to_UUID($feed_id), $account );

    run_fork {
        child {
            synchronize_feed($feed);
        }
    };

    redirect(qq|/feed/$feed_id|);
};

get '/feed/refresh' => sub {
    my $account = account();

    redirect('/') if session('refresh_lock');

    # todo logging
    session( 'refresh_lock', 1 );

    run_fork {
        child {
            my @feeds = reverse $account->feeds;
            foreach my $feed_rs (@feeds) {
                my $feed = Munge::Model::Feed->load( $feed_rs->uuid, $account );
                synchronize_feed($feed);
            }

            session( 'refresh_lock', 0 );
        }
    };

    redirect('/');
};

get '/feed/:feed' => sub {
    my $feed_id   = param('feed');
    my $account   = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    my $feed_info =
      { title => ucfirst($feed_id), description => 'Unread posts' };

    if ( to_UUID($feed_id) ) {
        $feed_info = $feed_view->feed_view($feed_id);
    }

    template 'feed/index',
      {
        feed  => $feed_info,
        feeds => $feed_view->all_feeds,
        items => feed_item_view($feed_id),
      };

    return;
};

sub synchronize_feed {
    my ($feed) = @_;

    debug( 'Synchronizing feed ' . $feed->link );

    try {
        debug('Start working on feed');
        $feed->synchronize(1);
        $feed->store();
        debug( 'Retrieved feeds: ' . scalar $feed->feed_items );
        return;
    }
    catch {
        debug $_;
        return;
    }

    return;
}

sub feed_item_view {
    my ($feed_id) = @_;

    $feed_id ||= 'today';

    my $account = account();
    my $view = Munge::Model::View::FeedItem->new( account => $account );

    return $view->today()     if $feed_id eq 'today';
    return $view->yesterday() if $feed_id eq 'yesterday';
    return $view->older()     if $feed_id eq 'archive';
    return $view->list($feed_id) if to_UUID($feed_id);
    return;
}

true;
