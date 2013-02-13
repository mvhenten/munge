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

hook 'before' => sub {
    return if ( request->path_info !~ m{^/API/v1} );

    header( 'Access-Control-Allow-Origin' => '*' );
    header( 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE' );
    header( 'Access-Control-Allow-Headers' => join( q|,|, qw|Origin Accept Content-Type X-Requested-With X-CSRF-Token|) );

    debug 'INSIDE BEFORE HOOK';
};

options '/*' => sub {
  header( 'Access-Control-Allow-Origin' => '*' );
  header( 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE' );
  header( 'Access-Control-Allow-Headers' => join( q|,|, qw|Origin Accept Content-Type X-Requested-With X-CSRF-Token|) );

  return {};
#  head(:ok) if request.request_method == "OPTIONS"
};

post '/account/login' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    debug "USERNAME: $username";

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load($username);

    if ( $account_rs && $account->validate( $account_rs, $password ) ) {
        session authenticated => true;
        session account       => { $account_rs->get_inflated_columns() };

        return { success => 1, id =>  session->{id} };
    }

    if ( not $account_rs ) {
        debug "Cannot load $username";
    }
    else {
        debug "Validation failed for $username";
    }

    return { succcess => 0 };
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
