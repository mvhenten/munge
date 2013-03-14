package Munge::Controller::Manage;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account feed_view|;
use Munge::Model::AccountFeed;
use Munge::Model::OPML;
use Munge::Types qw|UUID|;
use Munge::Util qw|is_url proc_fork uuid_string|;

prefix '/manage';

get '/import' => sub {

    template 'manage/import', { feeds => feed_view()->all_feeds, };
};

post '/import' => sub {
    my $upload = request->upload('subscriptions');
    
    die('NOT PORTED TO NEW DB STRUCTURE YET');

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
        debug($uri);

        my $subscription =
          Munge::Model::AccountFeed->subscribe( account(), $uri );

        return redirect( q|/feed/| . uuid_string( $subscription->feed->uuid ) );
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
