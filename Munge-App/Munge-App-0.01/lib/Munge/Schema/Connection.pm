package Munge::Schema::Connection;

use strict;
use warnings;

use Munge::Config;
use Munge::Schema;
use Data::Dumper;

{
    my $schema;

    sub schema {
        if ( $schema and not $schema->storage->connected ) {
            $schema = undef;
        }

        if ( not $schema ) {
            $schema = Munge::Schema->connect(
                Munge::Config::DSN(),
                Munge::Config::DB_USER(),
                Munge::Config::DB_PASSWORD(),
                {
                    RaiseError        => 1,
                    AutoCommit        => 1,
                    mysql_enable_utf8 => 1,
                    quote_names       => 1
                }
            );

        }

        return $schema;
    }
}

1;
