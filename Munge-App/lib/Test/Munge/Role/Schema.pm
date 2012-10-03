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
        return DBICx::TestDatabase->connect('Munge::Schema');
    }
}
