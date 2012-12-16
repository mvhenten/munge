use MooseX::Declare;

role Munge::Role::Schema {
    use Munge::Config;
    use Munge::Schema;
    use Munge::DBIC;

    has schema => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
        return Munge::DBIC::get_connection();
    }
}
