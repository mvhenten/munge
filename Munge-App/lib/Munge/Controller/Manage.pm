package Munge::Controller::Manage;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account feed_view synchronize_feed|;
use Munge::Model::AccountFeed;
use Munge::Model::OPML;
use Munge::Types qw|UUID|;
use Munge::Util qw|is_url proc_fork uuid_string|;
use URI;

prefix '/manage';

get '/import' => sub {

    template 'manage/import',
      { feeds => feed_view()->all_feeds, };
};

post '/import' => sub {
    my $upload = request->upload('subscriptions');

    my $opml_importer = Munge::Model::OPML->new( account => account() );
    my $imported_feeds = $opml_importer->import_feeds( $upload->tempname );

    # TODO Notify user that feeds have been importeded
    return redirect('/feed/');
};

post '/subscribe' => sub {
    my $url = param('feed_url');

    if ( my $uri = is_url($url) ) {

        my $subscription =
          Munge::Model::AccountFeed->subscribe( account(), $uri );

        synchronize_feed( $subscription->feed );

        return redirect(
            q|/feed/read/| . uuid_string( $subscription->feed->uuid ) );
    }

    template 'manage/subscribe', { url => $url, };
};

sub opml_feed_view {
    my ($imported_feeds) = @_;

    my @feeds =
      map {
        { title => $_->feed->title, description => $_->feed->description, }
      } @{$imported_feeds};

    return \@feeds;
}

1;
