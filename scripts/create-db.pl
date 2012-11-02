use DBIx::Class::Admin;

my $admin = DBIx::Class::Admin->new(
    schema_class => 'Munge::Schema',
    sql_dir      => 'sql',
    connect_info => { dsn => 'dbi:SQLite:test.db' },
);

$admin->deploy();
