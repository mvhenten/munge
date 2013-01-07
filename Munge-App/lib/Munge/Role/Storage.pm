use MooseX::Declare;
use Munge::Types qw|UUID Uri Account|;


role Munge::Role::Storage {
    use Munge::Storage;
    use Munge::Types qw|UUID|;
    use Carp::Assert;
    use Data::Dumper;

    requires qw|account schema|;

    has _storage => (
        is     => 'ro',
        isa    => 'Munge::Storage',
        lazy_build => 1,
    );

    sub NAMESPACE_PREFIX {
        return 'Munge::Schema::Result';
    }

    method _build__storage {
        $self->_get_storage( $self->account );
    }

    method store {
        my %values;

        if( $self->id ){
            $self->_storage->update( $self )
        }
        else {
            $self->_storage->create( $self )
        }

        foreach my $key ( keys %values ){
            my $method = "_set_$key";

            next if not $self->can( $method );
            $self->$method( $values{$key} );
        }
    }

    method delete {
        $self->_storage->delete( uuid => $self->uuid );
    }

    method load ( $class: UUID $uuid, Account $account, $storage? ){
        $storage ||= $class->_get_storage( $account );

        my $rs = $storage->load( uuid => $uuid );
        return if not $rs;

        delete( $rs->{account_id} );
        my @keys = grep { defined( $rs->{$_} ) } keys %{ $rs };

        delete( $rs->{@keys} );

        return $class->new(  %{ $rs }, account => $account );
    }

    method _schema_class ( $class: ){
        my ( $class_name ) = ( ref $class  || $class ) =~ m/.+::(\w+)/;

        return NAMESPACE_PREFIX() . "::$class_name";
    }

    method _get_storage ( $class: Account $account ) {
        return Munge::Storage->new( schema_name => $class->_schema_class(), account => $account );
    }


}
