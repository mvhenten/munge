package Munge::Controller::Feed;

use strict;
use warnings;

use Dancer ':syntax';
use Data::Dumper;
use Munge::Model::Account;
use Munge::Model::ItemView;
use Munge::Model::View::Feed;

prefix undef;

sub account {
    my $account = Munge::Model::Account->new()->find( session('account') );
    return $account;
}

get '/' => sub {
    my $account = account();
    
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    template 'feed/index',
      {
        feeds => $feed_view->all_feeds,
        items_today =>
          Munge::Model::ItemView->new( account => $account )->today(),
        items_yesterday =>
          Munge::Model::ItemView->new( account => $account )->yesterday(),
        items_older =>
          Munge::Model::ItemView->new( account => $account )->older(),
      };

};

true;
