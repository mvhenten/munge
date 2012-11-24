#!/usr/bin/env perl

use strict;
use warnings;

use lib './lib';

use Data::Dumper;
use Munge::Model::Account;
use Munge::Model::Feed;
use Try::Tiny;
use DateTime;

main(@ARGV);

sub usage {
    die "Usage: sync-feed.pl <account_id>\n";
}

sub main {
    my ($account_id) = @_;

    usage() if not($account_id);

    my $account = Munge::Model::Account->new()->find( { id => $account_id } );

    my @feeds = reverse $account->feeds;

    foreach my $rs (@feeds) {
        printf( "Synchronizing feed %s\n", $rs->link );

        try {
            my $feed = Munge::Model::Feed->load( $rs->uuid, $account );
            $feed->synchronize();
            $feed->store();
            
            warn "Syncrhonized ", scalar $feed->feed_items, " items";
        }
        catch {
            warn $_;
        }
    }
}
