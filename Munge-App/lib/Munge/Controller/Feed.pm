package Munge::Controller::Feed;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Model::Account;
use Munge::Model::ItemView;
use Munge::Model::View::Feed;
use Munge::Types qw|UUID|;

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

get '/feed/:feed' => sub {
    my $feed_id   = param('feed');
    my $account   = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    template 'feed/index',
      {
        feeds => $feed_view->all_feeds,
        items => feed_item_view($feed_id),
      };

};

sub feed_item_view {
    my ($feed_id) = @_;

    $feed_id ||= 'today';

    my $account = account();
    my $view = Munge::Model::ItemView->new( account => $account );

    return $view->today()     if $feed_id eq 'today';
    return $view->yesterday() if $feed_id eq 'yesterday';
    return $view->older()     if $feed_id eq 'archive';
    return $view->list($feed_id) if to_UUID($feed_id);
}

true;
