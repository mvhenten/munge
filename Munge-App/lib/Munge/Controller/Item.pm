package Munge::Controller::Item;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Model::Account;
use Munge::Model::FeedItem;
use Munge::Model::View::FeedItem;
use Munge::Model::View::Feed;
use Munge::Types qw|UUID|;

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

    my $model = Munge::Model::FeedItem->load( to_UUID($uuid), account() );
    $model->set_unread();
    $model->store();

    redirect "/item/$uuid#article";

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

    my $feed_info =
      { title => ucfirst($item_id), description => 'Unread posts' };

    return status('not_found') if not to_UUID($item_id);
    my $item = $item_view->get_item($item_id);

    return status('not_found') if not $item;

    my $model = Munge::Model::FeedItem->load( to_UUID($item_id), $account );
    
    if( not $model->read ){
        $model->set_read();
        $model->store();        
    }

    template 'feed/item',
      {
        feed  => $item,
        feeds => $feed_view->all_feeds,
        items => $item_view->list( $item->{feed_uuid} ),
      };

};

1;
