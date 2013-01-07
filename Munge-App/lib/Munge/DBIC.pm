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

    sub get_connection {
        my $conn = DBIx::Connector->new(
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

        return Munge::Schema->connect(
            sub {
                return $conn->dbh;
            },
            {
                mysql_enable_utf8 => 1,
                quote_names       => 1
            }
        );
    }
}

1;
