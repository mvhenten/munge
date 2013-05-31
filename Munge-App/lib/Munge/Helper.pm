package Munge::Helper;

=NAME Munge::Helper;

=DESCRIPTION

    Helper functions for controllers ( utilities that do thing swith dancer syntax )
    These functions are shared by different contollers.

=cut

use Dancer ':syntax';

use strict;
use warnings;
use Carp;

use Exporter::Lite;
use Munge::Model::Account;
use Munge::Model::View::Feed;
use Try::Tiny;
use Proc::Fork;
use Data::Dumper;

my @EXPORT_OK =
  qw|account init_account feed_view synchronize_feed get_account_feed_item|;

=item get_account_feed_item

Instantiate a new  Munge::Model::AccountFeedItem

=cut

sub get_account_feed_item {
    my ($uuid_string) = @_;

    my $uuid = to_UUID($uuid_string);
    return if not $uuid;

    my $account = account();

    my $model = Munge::Model::AccountFeedItem->find( $uuid, $account );

    if ( not $model ) {
        my $item_view =
          Munge::Model::View::FeedItem->new( account => $account );
        my $feed_item_data = $item_view->get_feed_item_data($uuid);

        $model = Munge::Model::AccountFeedItem->new(
            feed_item_uuid => $uuid,
            feed_uuid      => $feed_item_data->{feed_uuid},
            account        => $account,
        );
    }

    return $model;
}

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
