package Munge::Controller::Manage;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account feed_view|;
use Munge::Model::AccountFeed;
use Munge::Model::OPML;
use Munge::Model::Google::ReaderAPI;
use Munge::Types qw|UUID|;
use Munge::Util qw|is_url proc_fork uuid_string|;
use URI;

prefix '/manage';

get '/import/reader' => sub {
    my $base_uri = URI->new( request()->uri_base );

    debug( $base_uri->as_string );

    my $api = Munge::Model::Google::ReaderAPI->new(
        base_uri => $base_uri,
        account  => account()
    );

    template 'manage/import/reader',
      { authorization_url => $api->get_auth_code_uri->as_string };
};

get '/reader/token' => sub {
    my $base_uri = URI->new( request()->uri_base );

    my $api = Munge::Model::Google::ReaderAPI->new(
        base_uri => $base_uri,
        account  => account()
    );
    $api->import_feeds( param('code') );

    # TODO Notify user that feeds have been importeded
    return redirect('/feed/');
};

get '/import' => sub {

    my $api = Munge::Model::Google::ReaderAPI->new( account => account() );

    template 'manage/import', { feeds => feed_view()->all_feeds, };
};

post '/import' => sub {
    my $upload = request->upload('subscriptions');

    my $opml_importer = Munge::Model::OPML->new( account => account() );
    my $imported_feeds = $opml_importer->import_feeds( $upload->tempname );

    # TODO Notify user that feeds have been importeded
    return redirect('/feed/');

    #template 'manage/import',
    #  {
    #    feeds    => feed_view()->all_feeds,
    #    imported => opml_feed_view($imported_feeds),
    #  };

};

post '/subscribe' => sub {
    my $url = param('feed_url');

    if ( my $uri = is_url($url) ) {

        my $subscription =
          Munge::Model::AccountFeed->subscribe( account(), $uri );

        return redirect( q|/feed/| . uuid_string( $subscription->feed->uuid ) );
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
