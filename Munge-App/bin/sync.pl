#!/usr/bin/env perl

=NAME sync.pl
    Synchronize feeds.

    run this from a cronjob or manually.

    TODO clean this mess up :0)

=cut

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use Try::Tiny;

use File::Basename;
use File::Slurp qw|read_file write_file|;
use File::Util qw|existent|;
use FindBin;
use JSON qw|encode_json decode_json|;
use lib "$FindBin::Bin/../lib";
use Munge::Email;
use Munge::Model::Feed;
use Munge::Schema::Connection;
use Munge::Util qw|uuid_string|;
use LockFile::Simple qw|lock trylock unlock|;

main(@ARGV);

sub LOCK_FILE {
    return dirname(__FILE__) . '/sync.lock';
}


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
    my $lock = trylock( LOCK_FILE() );
    return if not $lock;

    my $schema = Munge::Schema::Connection->schema();

    my $rs = $schema->resultset('Munge::Schema::Result::Feed')->search();

    while ( my $row = $rs->next ) {
        my $uuid_string = uuid_string( $row->uuid );

        if ( recently_updated($row) ) {
            log_message(
                sprintf( 'skip feed %s:%s', $uuid_string, $row->title ) );
            next;
        }

        if ( is_blacklisted($uuid_string) ) {
            log_message( 'SKIP BLACKLISTED FEED: ' . $uuid_string );
            next;
        }

        log_message(
            printf( 'work on feed %s:%s', $uuid_string, $row->title ) );
        my $feed = Munge::Model::Feed->new( $row->get_inflated_columns() );

        try {
            my $error = $feed->synchronize();

            if ($error) {
                blacklist_feed( uuid_string( $feed->uuid ) );
                return;
            }

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
            blacklist_feed( uuid_string( $feed->uuid ) );
        }

    }

    my $duration = DateTime->now - SYNC_START_TIME();

    my $mail = Munge::Email->new(
        to      => Munge::Email::MUNGE_MAILER_ADDRESS(),
        subject => sprintf( '[CRON] Sync finished in %dm%ds',
            $duration->in_units( 'minutes', 'seconds' ) ),
        body => join( "\n", get_log_messages() ),
    );

    $mail->submit();
    write_blacklist();
    unlock(LOCK_FILE());
}

{
    my %blacklist;

    sub BLACKLIST_FILE {
        return dirname(__FILE__) . '/blacklist.json';
    }

    sub is_blacklisted {
        my ($uuid_string) = @_;

        init_blacklist();

        return defined( $blacklist{$uuid_string} );
    }

    sub blacklist_feed {
        my ($uuid_string) = @_;

        log_message( 'BLACKLISTING ' . $uuid_string );

        init_blacklist();

        $blacklist{$uuid_string} = 1;
    }

    sub init_blacklist {
        return if %blacklist;

        if ( existent( BLACKLIST_FILE() ) ) {
            my $blacklist = read_file( BLACKLIST_FILE() );

            if ($blacklist) {
                %blacklist = %{ decode_json($blacklist) };
            }
        }

        return;
    }

    sub write_blacklist {
        my $blacklist = encode_json( \%blacklist );
        write_file( BLACKLIST_FILE(), $blacklist );
        return;
    }
}

sub recently_updated {
    my ($row) = @_;

    return 0 if not $row->updated;

    my $duration = SYNC_START_TIME() - $row->updated;

    return $duration->in_units('minutes') < RECENT_IN_MINUTES();
}
