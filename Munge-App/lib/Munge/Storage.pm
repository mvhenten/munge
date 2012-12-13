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
        return $name->new();
    }

    method store ( $object ) {
        my $values = $self->_storable_attributes( $object );
        
        $values->{account_id} = $self->account->id;
        
        my $rs = $self->resultset( $self->schema_name )->update_or_create( $values );
        return $rs->get_inflated_columns();
    }
    
    method load ( $key, $value ) {
        my ( $result ) = $self->_find( $key, $value );
                        
        return defined( $result ) ?  { $result->get_inflated_columns() } : undef;
    }
    
    method delete ( $key, $value ) {
        my ( $result ) = $self->_find( $key, $value );
               
        for my $relation ($result->relationships ) {
            my $info = $result->relationship_info( $relation );
            
            
            if( $info->{attrs}->{cascade_delete} ){
                $result->$relation()->delete();
            }
        }
        
        $result->delete() if defined( $result );

        return;
    }
        
    method _find ( $key, $value ) {
        return $self->resultset( $self->schema_name )->find( { $key => $value, account_id => $self->account->id } );
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