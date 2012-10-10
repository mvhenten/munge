#!/bin/env perl

use strict;
use warnings;

use lib './lib';

use Data::Dumper;
use Munge::Model::Account;
use Munge::Model::Feed::Factory;
use Try::Tiny;

main(@ARGV);

sub usage {
    print "Usage: sync-feed.pl <account_id>\n";
}

sub main {
    my ($account_id) = @_;

    usage() if not($account_id);

    my $account = Munge::Model::Account->new()->find( { id => $account_id } );

    my @feeds = $account->feeds;

    foreach my $rs (@feeds) {
        printf( "Synchronizing feed %s\n", $rs->link );

        try {
            my $feed = Munge::Model::Feed::Factory->new()->load( $rs->id );
            $feed->synchronize();
        }
        catch {
            warn $_;
        }

    }
}
