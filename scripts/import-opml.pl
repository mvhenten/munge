#!/usr/bin/env perl

use strict;
use warnings;

use lib './lib';

use Data::Dumper;
use Munge::Model::Account;
use Munge::Model::Feed;
use URI;
use XML::XPath;

main(@ARGV);

sub usage {
    print "Usage: import.pl <subscriptions.xml> <account_id>\n";
    exit();
}

sub main {
    my ( $filename, $account_id ) = @_;

    usage() if not( $filename and $account_id );

    my $account = Munge::Model::Account->new()->find( { id => $account_id } );
    my $xp = XML::XPath->new( filename => $filename );
    my $nodeset = $xp->find('//outline');

    foreach my $node ( $nodeset->get_nodelist ) {        
        my $feed_uri = URI->new( $node->getAttribute('xmlUrl') );
        my $feed     = Munge::Model::Feed->create( $feed_uri, $account );
        
        $feed->store();
    }

    printf( "Imported %d feeds for acount %s\n",
        $nodeset->size, $account->email );
}
