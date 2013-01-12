package Munge::Controller::Manage;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account feed_view synchronize_feed|;
use Munge::Model::Account;
use Munge::Model::Feed::Item;
use Munge::Model::OPML;
use Munge::Model::View::Feed;
use Munge::Model::View::FeedItem;
use Munge::Types qw|UUID|;
use Munge::Util qw|is_url proc_fork|;

prefix '/manage';

get '/import' => sub {

    template 'manage/import', { feeds => feed_view()->all_feeds, };
};

post '/import' => sub {
    my $upload = request->upload('subscriptions');

    my $opml = Munge::Model::OPML->new(
        account  => account(),
        filename => $upload->tempname,
    );

    template 'manage/import',
      {
        feeds    => feed_view()->all_feeds,
        imported => opml_feed_view($opml),
      };

};

post '/subscribe' => sub {
    my $url = param('feed_url');

    if ( my $uri = is_url($url) ) {
        my $uuid = Munge::UUID->new( uri => $uri );

        my $feed = Munge::Model::Feed->new(
            link    => $uri->as_string,
            uuid    => $uuid->uuid_bin,
            account => account(),
        );

        $feed->store();

        proc_fork(
            sub {
                synchronize_feed($feed);
            }
        );

        return redirect( q|/feed/| . $uuid->uuid );
    }

    template 'manage/subscribe', { url => $url, };
};

sub opml_feed_view {
    my ($opml) = @_;

    my @feeds =
      map { { title => $_->title, description => $_->description, } }
      $opml->get_feeds;

    return \@feeds;
}

1;
