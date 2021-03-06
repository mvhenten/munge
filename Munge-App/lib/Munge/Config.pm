package Munge::Config;

use strict;
use warnings;

use YAML::Any qw|LoadFile|;
use File::Basename qw|fileparse|;
use Cwd qw|realpath|;

{
    my $config;

    sub config {
        return $config ||= LoadFile( APPLICATION_PATH() . '/config.yml' );
    }

}

sub APPLICATION_PATH {
    my ( $filename, $directories, $suffix ) = fileparse(__FILE__);

    my $path = realpath($directories);
    $path =~ s/\/lib\/Munge$//;

    return $path;
}

sub APP_EMAIL {
    return config()->{app_email};
}

sub HOST {
    return
         $ENV{DOTCLOUD_DB_MYSQL_HOST}
      || $ENV{OPENSHIFT_MYSQL_DB_HOST}
      || 'localhost';
}

sub PORT {
    return
         $ENV{DOTCLOUD_DB_MYSQL_PORT}
      || $ENV{OPENSHIFT_MYSQL_DB_PORT}
      || '3306';
}

sub DSN {
    return join( ':', config()->{plugins}->{DBIC}->{dsn}, HOST(), PORT() );
}

sub DB_USER {
    return
         $ENV{DOTCLOUD_DB_MYSQL_LOGIN}
      || $ENV{OPENSHIFT_MYSQL_DB_USERNAME}
      || config()->{plugins}->{DBIC}->{user};
}

sub DB_PASSWORD {
    return
         $ENV{DOTCLOUD_DB_MYSQL_PASSWORD}
      || $ENV{OPENSHIFT_MYSQL_DB_PASSWORD}
      || config()->{plugins}->{DBIC}->{pass};
}

1;
