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
use Munge::Helper qw|get_account_feed_item|;

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

get '/unread/:uuid' => sub {
    my $account_feed_item = get_account_feed_item( param('uuid') );

    return status('not_found') if not $account_feed_item;

    $account_feed_item->set_unread();
    $account_feed_item->store();

    redirect '/feed/read/' . uuid_string( $account_feed_item->feed_uuid );
};

get '/star/:uuid' => sub {
    my $account_feed_item = get_account_feed_item( param('uuid') );

    return status('not_found') if not $account_feed_item;

    $account_feed_item->toggle_star();
    $account_feed_item->store();

    redirect '/feed/read/' . uuid_string( $account_feed_item->feed_uuid );

    return;
};

get '/:feed' => sub {
    my $item_id   = param('feed');
    my $account   = account();
    my $item_view = Munge::Model::View::FeedItem->new( account => $account );
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    my $feed_item_uuid = to_UUID($item_id);

    return status('not_found') if not $feed_item_uuid;

    my $feed_item_data = $item_view->get_feed_item_data($item_id);

    return status('not_found') if not $feed_item_data;

    my $item_list_view = $item_view->list( $feed_item_data->{feed_uuid} );

    my $model =
      Munge::Model::AccountFeedItem->find( $feed_item_uuid, $account );

    if ( not $model ) {
        $model = Munge::Model::AccountFeedItem->new(
            feed_item_uuid => $feed_item_uuid,
            feed_uuid      => $feed_item_data->{feed_uuid},
            account        => $account,
        );
    }

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
