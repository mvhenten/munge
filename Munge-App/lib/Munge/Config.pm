package Munge::Config;

use strict;
use warnings;

use YAML::Any qw|LoadFile|;
use Cwd qw|realpath|;

{
    my $config;

    sub config {
        return $config ||= LoadFile( APPLICATION_PATH() . '/config.yml' );
    }

}

sub APPLICATION_PATH {
    my ($app_dir) = realpath(__FILE__) =~ m/(.+\/Munge-App\/)/;
    return $app_dir;
}

sub HOST {
    return $ENV{OPENSHIFT_MYSQL_DB_HOST} || 'localhost';
}

sub PORT {
    return $ENV{OPENSHIFT_MYSQL_DB_PORT} || '3306';
}

sub DSN {
    return join( ':', config()->{plugins}->{DBIC}->{dsn}, HOST(), PORT() );
}

sub DB_USER {
    return $ENV{OPENSHIFT_MYSQL_DB_USERNAME}
      || config()->{plugins}->{DBIC}->{user};
}

sub DB_PASSWORD {
    return $ENV{OPENSHIFT_MYSQL_DB_PASSWORD}
      || config()->{plugins}->{DBIC}->{pass};
}

1;
