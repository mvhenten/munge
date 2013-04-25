package Munge::Helper;

=NAME Munge::Helper;

=DESCRIPTION

    Helper functions for controllers ( utilities that do thing swith dancer syntax )
    These functions are shared by different contollers.

=cut

use Dancer ':syntax';

use strict;
use warnings;

use Exporter::Lite;
use Munge::Model::Account;
use Munge::Model::View::Feed;
use Try::Tiny;
use Proc::Fork;
use Data::Dumper;

my @EXPORT_OK = qw|account init_account feed_view synchronize_feed|;

=item account

Instantiates an account from current dancer session.

=cut

{
    my $account;

    sub init_account {
        $account = Munge::Model::Account->new()->find( session('account') );
        return $account;
    }

    sub account {
        return $account;
    }
}


=item feed_view

Retrieves the full list of feeds for the current account in sesion

=cut

sub feed_view {
    my $account = account();
    my $feed_view = Munge::Model::View::Feed->new( account => $account );

    return $feed_view;
}

=item synchronize_feed

Synchronizes a given feed using try/catch for safety

=cut

sub synchronize_feed {
    my ($feed) = @_;

    debug( 'Synchronizing feed ' . $feed->link );

    try {
        debug('Start working on feed');
        $feed->synchronize(1);
        $feed->store();
    }
    catch {
        debug $_;
    };

    return;
}

1;
