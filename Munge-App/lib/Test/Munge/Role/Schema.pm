use MooseX::Declare;

role Test::Munge::Role::Schema {
    use DBICx::TestDatabase;
    use Munge::Schema;

    has schema => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
        my $dbh =
          DBICx::TestDatabase->connect( 'Munge::Schema',
            { sqlite_unicode => 0 } );

        $dbh->{sqlite_handle_binary_nulls} = 0;
        $dbh->{sqlite_unicode}             = 0;

        return $dbh;
    }
}
