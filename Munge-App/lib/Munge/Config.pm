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

sub DB_USER {
    return config()->{plugins}->{DBIC}->{user};
}

sub DB_PASSWORD {
    return config()->{plugins}->{DBIC}->{pass};
}

1;
