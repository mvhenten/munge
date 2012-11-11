use MooseX::Declare;

use MooseX::StrictConstructor;

=head1 NAME

Munge::Storage

=head1 DESCRIPTION

Takes a class, stores it's public parts

=head1 SYNOPSIS

=cut

class Munge::Storage {
    use Data::Dumper;
    
    with 'Munge::Role::Schema';

    has account => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Account',
        required => 1,
    );
    
    has schema_name => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,    
    );

    has _schema_class => (
        is => 'ro',
        lazy_build => 1,
    );
    
    method _build__schema_class {
        my $name = $self->schema_name;
        return new $name;
    }

    method store ( $object ) {
        my $values = $self->_storable_attributes( $object );
        $values->{account_id} = $self->account->id;
        
        $self->resultset( $self->schema_name )->update_or_create( $values );
    }
    
    method load ( $key, $value ) {
        my ( $result ) = $self->resultset( $self->schema_name )->find( { $key => $value, account_id => $self->account->id } );

        return defined( $result ) ?  { $result->get_columns() } : {};
    }

    method delete ( $key, $value ) {
        my ( $result ) = $self->resultset( $self->schema_name )->find( { $key => $value, account_id => $self->_account_id } );

        return $result->delete() if defined( $result );
    }

    method _storable_attributes ( Object $object ) {
        my %storable_attributes;

        for my $key ( $self->_schema_class->columns() ){
            next if not $object->can( $key );

            my $value = $object->$key();
            next if not defined($value);

            $storable_attributes{$key} = $value;
        }

        return \%storable_attributes;
    }
}