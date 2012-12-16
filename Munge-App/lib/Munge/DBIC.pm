package Munge::DBIC;

=NAME Munge::DBIC;

=DESCRIPTION

Code cache for database connection.
TODO study this more, cleanup stale connections, etc.

=cut

use Moose;
use Munge::Config;

use strict;
use warnings;

{
    my $schema;

    sub get_connection {
        if ( not $schema ) {
            $schema = Munge::Schema->connect(
                Munge::Config::DSN(),
                Munge::Config::DB_USER(),
                Munge::Config::DB_PASSWORD(),
                undef,
                { mysql_enable_utf8 => 1, quote_names => 1 }
            );
        }

        return $schema;
    }
}

1;
