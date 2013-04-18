use MooseX::Declare;

role Munge::Role::Account {

    has account => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Account',
        required => 1,
    );
}
