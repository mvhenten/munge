package Munge::App;

use Dancer ':syntax';
use Munge::Controller::Feed;
use Munge::Controller::Account;

our $VERSION = '0.1';

prefix undef;

get '/' => sub {
    template 'index';
};

get '/test' => sub {

};

true;

#package myapp;
#use Dancer ':syntax';
#use myapp::admin;
#
#prefix undef;
#
#get '/' => sub {...};
#
#1;
