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
        return Munge::Schema->connect( Munge::Config::DSN(),
            Munge::Config::DB_USER(), Munge::Config::DB_PASSWORD() );
    }
}
