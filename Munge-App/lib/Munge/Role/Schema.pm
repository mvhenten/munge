use MooseX::Declare;

role Munge::Role::Schema {
    use Munge::Config;

    has schema => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
        warn 'builder';
        return Munge::Schema->connect( Munge::Config::DSN() );
    }
}
