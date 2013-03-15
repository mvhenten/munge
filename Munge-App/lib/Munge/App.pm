package Munge::App;
use strict;
use warnings;

# ABSTRACT: turns baubles into trinkets

use Dancer ':syntax';

# controllers
use Munge::Controller::Account;
use Munge::Controller::Feed;
use Munge::Controller::Item;
use Munge::Controller::Manage;
use Munge::Controller::REST;

# most not needed, but preloading
use Munge::Model::Account;
use Munge::Model::Feed;
use Munge::Model::Feed::Client;
use Munge::Model::FeedItem;
use Munge::Model::View::Feed;
use Munge::Model::View::FeedItem;
use Munge::Storage;
use Munge::UUID;
use Munge::Helper qw|account|;

our $VERSION = '0.1';

prefix undef;

sub set_cors_headers {
    header( 'Access-Control-Allow-Origin'  => '*' );
    header( 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE' );
    header(
        'Access-Control-Allow-Headers' => join( q|,|,
            qw|Origin Accept Content-Type X-Requested-With X-CSRF-Token| )
    );

    return;
}

sub is_api_request {
    return request->path_info =~ m{^/API/v1};
}

hook before_template_render => sub {
    my ($template_hash) = @_;

    my $session_account = session('account');

    $template_hash->{account} = { email => $session_account->{email}, };

    return $template_hash;
};

hook 'before' => sub {
    set_cors_headers() if is_api_request();

    if ( not session('authenticated')
        and request->path_info !~ m{/account/(login|create)$} )
    {
        send_error( 'Autentication required', 403 ) if is_api_request();
        redirect 'account/login';
    }
};

get '/logout' => sub {
    session->destroy();

    redirect 'account/login';
};

get '/' => sub {
    redirect '/feed/';
};

true;
