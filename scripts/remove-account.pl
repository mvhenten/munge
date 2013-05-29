#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../Munge-App/lib";

use Data::Dumper;
use Munge::Model::Account;


main(@ARGV);

sub usage {
    print "Usage: remove-account.pl <email>\n";
    exit();
}

sub main {
    my ( $email, $password ) = @_;

    usage() if not( like_email($email)  );

    my $success = Munge::Model::Account->new()->delete( $email );

    return print qq|could not remove account $email\n| if not $success;
    return print qq|removed account $email\n|;
}

sub like_email {
    my ( $email ) = @_;
    return ( $email and $email =~ /\w+@\w+[.]\w{2,6}/ );
}

