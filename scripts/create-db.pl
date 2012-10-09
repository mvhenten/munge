use DBIx::Class::Admin;

my $admin = DBIx::Class::Admin->new(
    schema_class => 'Munge::Schema',
    sql_dir      => 'sql',
    connect_info => { dsn => 'dbi:SQLite:Munge-App/test.db' },
);

$admin->deploy();
