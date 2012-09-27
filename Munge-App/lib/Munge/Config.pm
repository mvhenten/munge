package Munge::Config;

use YAML::Any qw|LoadFile|;

{
    my $config;

    sub config {
        return $config ||= LoadFile('config.yml');
    }

}

sub DSN {
    return config()->{plugins}->{DBIC}->{dsn};
}

#use MooseX::Declare;

#class Munge::Model::Feed::Parser {

#use YAML::Any qw|LoadFile|;
#use MooseX::Singleton;
#use Moose;

#
#has config => (
#    is      => 'ro',
#    isa     => 'HashRef',
#    lazy_build => 1
#);
#
#sub _build_config {
#    my ( $self ) = @_;
#
#
#}
#
1;
