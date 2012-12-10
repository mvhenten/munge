package Munge::Helper;
use strict;
use warnings;

use Munge::Model::Account;
use Munge::Model::View::Feed;
use Dancer ':syntax';
use Exporter::Lite;

my @EXPORT_OK = qw|account feed_view|;

sub account {
    my $account = Munge::Model::Account->new()->find( session('account') );
    return $account;
}

sub feed_view {
    my $account = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );
}

1;
