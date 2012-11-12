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
        my $filename = ':memory:';    # use in-memory database

        my $schema =
          Munge::Schema->connect( "DBI:SQLite:$filename", '', '',
            { sqlite_unicode => 0 } )
          or die "failed to connect to DBI:SQLite:$filename (Munge::Schema)";

        $schema->deploy;
        return $schema;
    }
}
