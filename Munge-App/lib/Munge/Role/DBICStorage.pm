use MooseX::Declare;

role Munge::Role::DBICStorage ( Any :$schema ) {

    has _account => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Account',
        init_arg => 'account',
        required => 1,
        handles  => { _account_id => 'id' },
    );

    method store () {
        $self->resultset( $schema )->update_or_create( $self->_storable_attributes );
    }

    method load ( $key, $value ) {
        my ( $result ) = $self->resultset( $schema )->find_or_create( { $key => $value, account_id => $self->_account_id } );

        return $result->get_columns();
    }

    method _storable_attributes () {
        my @attribute_names = grep { $_ !~ /^_/ } $self->meta->get_attribute_list();
        my %storable_attributes;

        for my $key ( @attribute_names ){
            $storable_attributes{$key} = $self->$key();
        }

        return \%storable_attributes;
    }
}
