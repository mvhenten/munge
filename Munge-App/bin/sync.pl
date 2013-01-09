#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use Try::Tiny;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Munge::Model::Feed;
use Munge::Schema::Connection;

main(@ARGV);

{
    my $start;

    sub SYNC_START_TIME {
        if ( not $start ) {
            $start = DateTime->now();
        }
        return $start;
    }
}

{
    my %users;

    sub get_account {
        my ($account_id) = @_;

        if ( not %users ) {
            my $schema = Munge::Schema::Connection->schema();
            my $rs =
              $schema->resultset('Munge::Schema::Result::Account')->search();

            %users = map { $_->id => $_ } $rs->all();
        }

        return $users{$account_id};
    }
}

sub RECENT_IN_MINUTES {
    return 30;
}

sub main {
    my $schema = Munge::Schema::Connection->schema();

    my $rs = $schema->resultset('Munge::Schema::Result::Feed')->search();

    while ( my $row = $rs->next ) {
        if ( recently_updated($row) ) {
            printf "skip feed %s:%s\n", $row->id, $row->title;
            next;
        }

        printf "work on feed %s:%s\n", $row->id, $row->title;
        my $feed = Munge::Model::Feed->new( $row->get_inflated_columns(),
            account => get_account( $row->account_id ) );

        try {
            $feed->synchronize();
            $feed->store();

            printf " * syncrhonized feed items %s:%s\n", $feed->id,
              $feed->title;
        }
        catch {
            warn $_;
        }

    }
}

sub recently_updated {
    my ($row) = @_;

    return 0 if not $row->updated;

    my $duration = SYNC_START_TIME() - $row->updated;

    return $duration->in_units('minutes') < RECENT_IN_MINUTES();
}

