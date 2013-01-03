package Munge::DBIC;

=NAME Munge::DBIC;

=DESCRIPTION

Code cache for database connection.
TODO study this more, cleanup stale connections, etc.

=cut

use Moose;
use Munge::Config;
use DBIx::Connector;

use strict;
use warnings;

{
    my $schema;

    sub get_connection {
        if ( not $schema ) {
            my $conn = DBIx::Connector->new(
                Munge::Config::DSN(),
                Munge::Config::DB_USER(),
                Munge::Config::DB_PASSWORD(),
                {
                    RaiseError => 1,
                    AutoCommit => 1,
                }
            );

            $schema = Munge::Schema->connect( sub { return $conn->dbh },
                undef, { mysql_enable_utf8 => 1, quote_names => 1 } );
        }

        return $schema;
    }
}

1;
