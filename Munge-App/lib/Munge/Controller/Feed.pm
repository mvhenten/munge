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

get '/item/:feed' => sub {
    my $item_id   = param('feed');
    my $account   = account();
    my $item_view = Munge::Model::ItemView->new( account => $account );
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    my $feed_info =
      { title => ucfirst($item_id), description => 'Unread posts' };

    return not_found() if not to_UUID($item_id);

    my $item = $item_view->get_item($item_id);

    return not_found() if not $item;

    template 'feed/item',
      {
        feed  => $item,
        feeds => $feed_view->all_feeds,
        items => $item_view->list( $item->{feed_uuid} ),
      };

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

};

sub not_found {
    status 'not_found';
}

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
