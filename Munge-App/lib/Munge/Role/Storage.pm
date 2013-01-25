use MooseX::Declare;
use Munge::Types qw|UUID Uri Account|;


role Munge::Role::Storage {
    use Munge::Storage;
    use Munge::Types qw|UUID|;
    use Carp::Assert;
    use Data::Dumper;

    has _storage => (
        is     => 'ro',
        isa    => 'Munge::Storage',
        lazy_build => 1,
    );

    sub NAMESPACE_PREFIX {
        return 'Munge::Schema::Result';
    }

    method _build__storage {
        return $self->_get_storage();
    }

    method store {
        my %columns = $self->_storage->store( $self );

        return $self->new( %columns );
    }

    method delete {
        $self->_storage->delete( uuid => $self->uuid );
    }

    method load ( $class: UUID $uuid, $storage? ){
        $storage ||= $class->_get_storage();

        my $columns = $storage->load( uuid => $uuid );
        return if not $columns;

        return $class->_load_from_resultrow( $columns );
    }

    method search ( $class: HashRef $search, $storage ? ){
        $storage ||= $class->_get_storage();
        my @instances = map { $class->_load_from_resultrow( $_ ) } $storage->search( $search );

        return @instances;
    }

    method _load_from_resultrow( $class: $rs ) {
        my @keys = grep { defined( $rs->{$_} ) } keys %{ $rs };

        delete( $rs->{@keys} );

        return $class->new(  %{ $rs } );
    }

    method _schema_class ( $class: ){
        my ( $class_name ) = ( ref $class  || $class ) =~ m/.+::(\w+)/;

        return NAMESPACE_PREFIX() . "::$class_name";
    }

    method _get_storage ( $class: ) {
        return Munge::Storage->new( schema_name => $class->_schema_class() );
    }


}
