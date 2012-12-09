package Munge::Config;

use strict;
use warnings;

use YAML::Any qw|LoadFile|;
use Cwd qw|realpath|;

{
    my $config;

    sub config {
        return $config ||= LoadFile( APPLICATION_PATH() .  '/config.yml');
    }

}


sub APPLICATION_PATH {
    my ($app_dir) = realpath(__FILE__) =~ m/(.+\/Munge-App\/)/;
    return $app_dir;
}

sub DSN {
    return config()->{plugins}->{DBIC}->{dsn};
}

sub DB_USER {
    return config()->{plugins}->{DBIC}->{user};
}

sub DB_PASSWORD {
    return config()->{plugins}->{DBIC}->{pass};
}

1;
