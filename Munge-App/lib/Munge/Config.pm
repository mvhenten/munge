package Munge::Config;

use YAML::Any qw|LoadFile|;

{
    my $config;

    sub config {
        return $config ||= LoadFile('config.yml');
    }

}

sub DSN {
    return 'dbi:SQLite:db/test.db';

    #    return config()->{plugins}->{DBIC}->{dsn};
}

1;
