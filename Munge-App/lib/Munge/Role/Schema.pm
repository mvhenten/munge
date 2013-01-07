use MooseX::Declare;

role Munge::Role::Schema {
    use Munge::Config;
    use Munge::Schema;

    has schema => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
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
