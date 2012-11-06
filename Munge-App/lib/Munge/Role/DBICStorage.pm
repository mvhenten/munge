use MooseX::Declare;

role Munge::Role::DBICStorage ( Any :$schema ) {
    use Data::Dumper;

    requires 'resultset';

#    with 'Munge::Role::Schema';

    has _account => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Account',
        init_arg => 'account',
        required => 1,
        handles  => { _account_id => 'id' },
    );

    has _schema_class => (
        is => 'ro',
        isa => $schema,
        default => sub { return new $schema }
    );

    method store () {
        my $values = $self->_storable_attributes;

        $values->{account_id} = $self->_account_id;
        $self->resultset( $schema )->update_or_create( $values );
    }

    method load ( $key, $value ) {
        my ( $result ) = $self->resultset( $schema )->find( { $key => $value, account_id => $self->_account_id } );

        return defined( $result ) ?  { $result->get_inflated_columns() } : {};
    }

    method _storage_delete ( $key, $value ) {
        my ( $result ) = $self->resultset( $schema )->find( { $key => $value, account_id => $self->_account_id } );

        return $result->delete() if defined( $result );
    }

    method _storable_attributes () {
        my %storable_attributes;

        for my $key ( $self->_schema_class->columns() ){
            next if not $self->can( $key );

            my $value = $self->$key();
            next if not defined($value);

            $storable_attributes{$key} = $value;
        }

        return \%storable_attributes;
    }
}
