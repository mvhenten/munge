#!/usr/bin/env perl

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

sub LOCK_FILE {
    return dirname(__FILE__) . '/sync.lock';
}

sub SQL {
    return
      'SELECT uuid FROM feed WHERE NOT blacklist = 1 AND updated < DATE_SUB( NOW(), INTERVAL 1 DAY ) LIMIT 10';
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

sub main {
    my $lock = trylock( LOCK_FILE() );

    if ( not $lock ) {
        printf( "Cannot open lockfile %s, exiting\n", LOCK_FILE() );
        return;
    }

    my $schema = Munge::Schema::Connection->schema();

    my $dbh    = $schema->storage->dbh;
    my $result = $dbh->selectcol_arrayref( SQL() );

    foreach my $uuid ( @{$result} ) {
        my $feed = Munge::Model::Feed->load($uuid);

        if ( not $feed->synchronize() ) {
            log_message(
                sprintf( 'blacklisting %s', $feed->title || $feed->link ) );
            $feed->set_blacklist(1);
            $feed->store;
            next();
        }

        log_message(
            sprintf( 'synchronized %s', $feed->title || $feed->link ) );
        $feed->store();

    }

    my $duration = DateTime->now - SYNC_START_TIME();

    my $mail = Munge::Email->new(
        to      => Munge::Email::MUNGE_MAILER_ADDRESS(),
        subject => sprintf( '[CRON] Sync finished in %dm%ds',
            $duration->in_units( 'minutes', 'seconds' ) ),
        body => join( "\n", get_log_messages() ),
    );

    printf( "%s\n", $mail->subject );

    $mail->submit();
    unlock( LOCK_FILE() );

}

main();
