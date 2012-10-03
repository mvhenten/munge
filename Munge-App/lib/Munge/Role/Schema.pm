use MooseX::Declare;

role Munge::Role::Schema {

    has schema => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
        warn 'builder';
        return Munge::Schema->connect();
    }
}
