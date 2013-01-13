#!/usr/bin/env perl

use JSON qw|decode_json|;
use strict;
use warnings;

run( @ARGV );

sub run {
    my ( $cmd ) = @_;
    
    open my $fh, "<", "/home/dotcloud/environment.json" or die $!;
    my $json = decode_json(join '', <$fh>);
    
    foreach my $key ( keys %{$json}  ) {
        $ENV{$key} = $json->{$key};
    }
    
    system( "$cmd" );
}