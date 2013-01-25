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

get '/unread/:uuid' => sub {
    my $uuid = param('uuid');

    my $account = account();

    my $model = Munge::Model::FeedItem->load( to_UUID($uuid), $account );
    $model->set_unread();
    $model->store();

    my ($feed) =
      Munge::Model::Feed->search( $account, { id => $model->feed_id } );

    redirect '/feed/' . uuid_string( $feed->uuid );
};

get '/star/:uuid' => sub {
    my $uuid = param('uuid');

    my $model = Munge::Model::FeedItem->load( to_UUID($uuid), account() );
    $model->toggle_star();
    $model->store();

    redirect "/item/$uuid#article";

    return;
};

get '/:feed' => sub {
    my $item_id   = param('feed');
    my $account   = account();
    my $item_view = Munge::Model::View::FeedItem->new( account => $account );
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    return status('not_found') if not to_UUID($item_id);
    my $item           = $item_view->get_item($item_id);
    my $item_list_view = $item_view->list( $item->{feed_uuid} );

    return status('not_found') if not $item;

    #    warn Dumper $item;

    my $model =
      Munge::Model::AccountFeedItem->load( to_UUID($item_id),
        to_UUID( $item->{feed_uuid_string} ), $account );

    #my $model = Munge::Model::FeedItem->load( to_UUID($item_id), $account );
    #
    if ( ( not $model->read ) or $model->starred ) {
        $model->unset_star();
        $model->set_read();
        $model->store();
    }

    template 'feed/item',
      {
        feed  => $item,
        feeds => $feed_view->all_feeds,
        items => $item_list_view,
      };

};

1;
