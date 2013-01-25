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
use Munge::Util qw|uuid_string|;

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

sub RECENT_IN_MINUTES {
    return 30;
}

sub main {
    my $schema = Munge::Schema::Connection->schema();

    my $rs = $schema->resultset('Munge::Schema::Result::Feed')->search();

    while ( my $row = $rs->next ) {
        if ( recently_updated($row) ) {
            printf "skip feed %s:%s\n", uuid_string( $row->uuid ), $row->title;
            next;
        }

        printf "work on feed %s:%s\n", uuid_string( $row->uuid ), $row->title;
        my $feed = Munge::Model::Feed->new( $row->get_inflated_columns() );

        try {
            $feed->synchronize();
            $feed->store();

            printf " * synchronized feed items %s:%s\n",
              uuid_string( $feed->uuid ),
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
