use MooseX::Declare;

class Munge::Model::Feed::ParserItem {
    use Data::UUID qw|NameSpace_URL|;

    has entry => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
        handles  => [
            qw|
              title
              link
              summary
              |
        ],
    );

    has uuid => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has uuid_bin => (
        is         => 'ro',
        isa        => 'Value',
        lazy_build => 1,
    );

    method _build_uuid {
        my $uuid = new Data::UUID;
        return $uuid->create_from_name_str( NameSpace_URL, $self->link );
    }

    method _build_uuid_bin {
        my $uuid = new Data::UUID;

        return $uuid->from_string( $self->uuid );
    }

}
