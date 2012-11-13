#!/usr/bin/env perl

use strict;
use warnings;

use lib './lib';

use Data::Dumper;
use Munge::Model::Account;

main(@ARGV);

sub usage {
    print "Usage: create-account.pl <email> <password>\n";
    exit();
}

sub main {
    my ( $email, $password ) = @_;

    usage() if not( like_email($email) and $password );
    
    my $account = Munge::Model::Account->new()->create( $email, $password );
    
    print sprintf( 'Created account "%s" with uid "%d"', $email, $account->id );
}

sub like_email {
    my ( $email ) = @_;
    return ( $email and $email =~ /\w+@\w+[.]\w{2,6}/ );
}
