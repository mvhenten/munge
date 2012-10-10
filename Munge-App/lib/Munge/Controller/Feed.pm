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

    # Munge::Model::Account->new( schema => $self->schema )->find

    my $account = Munge::Model::Account->new()->find( session('account') );
    my @feeds   = map {
        { $_->get_inflated_columns() }
    } $account->feeds;

    #return Dumper( \@feeds );

    template 'feed/index',
      {
        feeds => \@feeds,
        items => Munge::Model::ItemView->new()->list_account($account),
      };

};

true;
