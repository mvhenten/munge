package Munge::App;

# ABSTRACT: turns baubles into trinkets

use Dancer ':syntax';
use Munge::Controller::Feed;
use Munge::Controller::Item;
use Munge::Controller::Account;

our $VERSION = '0.1';

prefix undef;

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
