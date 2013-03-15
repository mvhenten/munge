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
use Munge::Email;

main(@ARGV);

{
    my $start;

    sub SYNC_START_TIME {
        if ( not $start ) {
            $start = DateTime->now();
        }
        return $start;
    }

    my @logs;

    sub log_message {
        my ($message) = @_;
        my $log_message = sprintf( '%s: %s', DateTime->now, $message );

        print "$log_message\n";
        push( @logs, $log_message );
    }

    sub get_log_messages {
        return @logs;
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
            log_message(
                sprintf( 'skip feed %s:%s',
                    uuid_string( $row->uuid ),
                    $row->title )
            );
            next;
        }

        log_message(
            printf(
                'work on feed %s:%s',
                uuid_string( $row->uuid ),
                $row->title
            )
        );
        my $feed = Munge::Model::Feed->new( $row->get_inflated_columns() );

        try {
            $feed->synchronize();
            $feed->store();

            log_message(
                printf(
                    ' * synchronized feed items %s:%s',
                    uuid_string( $feed->uuid ),
                    $feed->title
                )
            );
        }
        catch {
            log_message("ERROR $_");
        }

    }

    my $duration = DateTime->now - SYNC_START_TIME();

    my $mail = Munge::Email->new(
        to      => $ENV{MUNGE_SMTP_USERNAME},
        subject => sprintf( 'Sync finished in %dm%ds',
            $duration->in_units( 'minutes', 'seconds' ) ),
        body => join( "\n", get_log_messages() ),
    );

    $mail->submit();
}

sub recently_updated {
    my ($row) = @_;

    return 0 if not $row->updated;

    my $duration = SYNC_START_TIME() - $row->updated;

    return $duration->in_units('minutes') < RECENT_IN_MINUTES();
}
