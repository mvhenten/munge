package Munge::Controller::REST;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;

use Munge::Helper qw|account synchronize_feed feed_view|;
use Munge::Model::View::Feed;
use Munge::Model::View::FeedItem;

set serializer => 'JSON';

prefix '/API/v1';



get '/user/:id/' => sub {
    { foo => 42,
      number => 100234,
      list => [qw(one two three)],
    }
};

options '/feeds' => sub {
  header( 'Access-Control-Allow-Origin' => '*' );
  header( 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE' );
  header( 'Access-Control-Allow-Headers' => join( q|,|, qw|Origin Accept Content-Type X-Requested-With X-CSRF-Token|) );
  
  return;
#  head(:ok) if request.request_method == "OPTIONS"
};


get '/feeds' => sub {
    my $feed_view = feed_view();

    return {
        items => [],
        feeds => $feed_view->all_feeds, 
    }    

};

get '/feeds/today' => sub {
    my $feed_view = feed_view();

    my $view = Munge::Model::View::FeedItem->new( account => account() );

    return {
        items => $view->today(),
        feeds => $feed_view->all_feeds, 
    }    
};

1;