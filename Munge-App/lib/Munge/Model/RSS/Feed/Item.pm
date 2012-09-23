use MooseX::Declare;

class Munge::Model::RSS::Feed::Item {
    use Data::UUID qw|NameSpace_URL|;

    has entry => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
        handles  => [
            qw|
              title
              link
              content
              |
        ],
    );

    has uuid => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    method _build_uuid {
        my $uuid = new Data::UUID;
        return $uuid->create_from_name_str( NameSpace_URL, $self->link );
    }

}
