package Munge::Controller::Item;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Model::Account;
use Munge::Model::AccountFeedItem;
use Munge::Model::View::FeedItem;
use Munge::Model::View::Feed;
use Munge::Types qw|UUID|;
use Munge::Util qw|uuid_string|;

prefix '/item';

sub validate {
    my $uuid = param('uuid');

    return status('not_found') if not to_UUID($uuid);

    return;
}

sub account {
    my $account = Munge::Model::Account->new()->find( session('account') );
    return $account;
}

sub _get_account_feed_item {
    my ( $uuid_string ) = @_;

    my $uuid = to_UUID( $uuid_string );
    return if not $uuid;

    my $account         = account();
    my $item_view       = Munge::Model::View::FeedItem->new( account => $account );
    my $feed_item_data  = $item_view->get_feed_item_data( $uuid );

    return if not $feed_item_data;

    my $model = Munge::Model::AccountFeedItem->load( $uuid,
        to_UUID( $feed_item_data->{feed_uuid} ), $account );

    return $model;

}

get '/unread/:uuid' => sub {
    my $account_feed_item = _get_account_feed_item(  param('uuid') );

    return status('not_found') if not $account_feed_item;

    $account_feed_item->set_unread();
    $account_feed_item->store();

    redirect '/feed/' . uuid_string( $account_feed_item->feed_uuid );
};

get '/star/:uuid' => sub {
    my $account_feed_item = _get_account_feed_item(  param('uuid') );

    return status('not_found') if not $account_feed_item;

    $account_feed_item->toggle_star();
    $account_feed_item->store();

    redirect '/feed/' . uuid_string( $account_feed_item->feed_uuid );

    return;
};

get '/:feed' => sub {
    my $item_id   = param('feed');
    my $account   = account();
    my $item_view = Munge::Model::View::FeedItem->new( account => $account );
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    return status('not_found') if not to_UUID($item_id);

    my $feed_item_data = $item_view->get_feed_item_data($item_id);

    return status('not_found') if not $feed_item_data;

    my $item_list_view = $item_view->list( $feed_item_data->{feed_uuid} );


    my $model = Munge::Model::AccountFeedItem->load( to_UUID($item_id),
        to_UUID( $feed_item_data->{feed_uuid} ), $account );

    #my $model = Munge::Model::FeedItem->load( to_UUID($item_id), $account );
    #
    if ( ( not $model->read ) or $model->starred ) {
        $model->unset_star();
        $model->set_read();
        $model->store();
    }

    template 'feed/item',
      {
        feed  => $feed_item_data,
        feeds => $feed_view->all_feeds,
        items => $item_list_view,
      };

};

1;
