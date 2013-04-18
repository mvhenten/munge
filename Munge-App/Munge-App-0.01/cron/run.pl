#!/usr/bin/env perl
use JSON qw|decode_json|;
use strict;
use warnings;

=HEAD script runner for dotcloud

this is a workaround for dotcloud's cron: we need information from the
environment.json to be available for our scripts, and set PER5LIB correctly

=cut

run( @ARGV );

sub run {
    my ( $cmd ) = @_;
    
    open my $fh, "<", "/home/dotcloud/environment.json" or die $!;
    my $json = decode_json(join '', <$fh>);
    close $fh;
    
    foreach my $key ( keys %{$json}  ) {
        $ENV{$key} = $json->{$key};
    }

    $ENV{'PERL5LIB'} = '/home/dotcloud/perl5/lib/perl5';
    
    system( "PERL5LIB=/home/dotcloud/perl5/lib/perl5 /opt/perl5/perls/current/bin/perl $cmd" );
    return;
}