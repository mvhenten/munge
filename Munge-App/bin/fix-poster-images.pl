#!/usr/bin/env perl
use utf8;

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use Try::Tiny;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Munge::Model::FeedItem;
use Munge::Schema::Connection;
use Munge::Util qw|uuid_string|;
$| = 1;    # Disable buffering on STDOUT ;)

main(@ARGV);

sub main {
    my $schema = Munge::Schema::Connection->schema();

    my $rs =
      $schema->resultset('Munge::Schema::Result::FeedItem')
      ->search( {}, { rows => undef } );
    my $count = $rs->count();
    my @errors;

    my $counter = 0;

    while ( my $row = $rs->next ) {
        $counter++;
        my $item = Munge::Model::FeedItem->new( $row->get_inflated_columns() );

        $item->_clear_poster_image();
        my $title = $item->title;

        utf8::encode($title);

        try {
            $item->store();
            printf( "Working on item: %s/%s - %s\n", $counter, $count, $title );
        }
        catch {
            push( @errors, $_ );
            printf( "FAILED item: %s/%s - %s\n", $counter, $count, $title );
        }

    }
}
