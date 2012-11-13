package Munge::Controller::Feed;

use Dancer ':syntax';
use Data::Dumper;
use Munge::Model::Account;
use Munge::Model::ItemView;

prefix undef;

sub account {
    my $account = Munge::Model::Account->new()->find( session('account') );
    return $account;
}

get '/' => sub {
    my $account = account();

    my @feeds   = map {
        { $_->get_inflated_columns() }
    } $account->feeds;

    template 'feed/index',
      {
        feeds => \@feeds,
        items_today =>
          Munge::Model::ItemView->new( account => $account )->today(),
        items_yesterday =>
          Munge::Model::ItemView->new( account => $account )->yesterday(),
        items_older =>
          Munge::Model::ItemView->new( account => $account )->older(),
      };

};

true;
