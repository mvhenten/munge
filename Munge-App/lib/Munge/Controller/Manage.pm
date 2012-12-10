package Munge::Controller::Manage;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Model::Account;
use Munge::Model::FeedItem;
use Munge::Model::View::FeedItem;
use Munge::Model::View::Feed;
use Munge::Model::OPML;
use Munge::Types qw|UUID|;
use Munge::Helper qw|account feed_view|;

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

sub opml_feed_view {
    my ($opml) = @_;

    my @feeds =
      map { { title => $_->title, description => $_->description, } }
      $opml->get_feeds;

    return \@feeds;
}

1;
