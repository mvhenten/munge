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

hook before_template_render => sub {
    my ($template_hash) = @_;

    my $session_account = session('account');

    $template_hash->{account} = { email => $session_account->{email}, };

    return $template_hash;
};

hook 'before' => sub {
    if ( ( not session('account') and not session('authenticated') )
        && request->path_info !~ m{^/account/(login|create)} )
    {

        #        var requested_path => request->path_info;
        request->path_info('/account/login');
        redirect 'account/login';
        return;
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
