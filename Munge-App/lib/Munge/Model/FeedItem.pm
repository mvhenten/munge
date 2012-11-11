use MooseX::Declare;

class Munge::Model::FeedItem {

    use Munge::Types qw|UUID|;
    use DateTime;

    with 'Munge::Role::Schema';

    #account     => $self->_account,
    #feed_id     => $self->feed_id,
    #uuid        => $item->uuid_bin,
    #link        => $item->link,
    #title       => $item->title,
    #description => $item->content,

    has uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has feed_id => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
    );

    has link => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has title => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has description => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has read => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0
    );

    has starred => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0
    );

    has created => (
        is         => 'ro',
        isa        => 'DateTime',
        lazy_build => 1
    );

    sub _build_created {
        return DateTime->now();
    }

    #
    #has _storage_values => (
    #    is => 'ro',
    #    isa => 'HashRef',
    #    traits => ['Hash'],
    #    lazy_build => 1,
    #    handles => {
    #        _get_description => [ get => 'description' ],
    #          feed_id        => [ get => 'id' ],
    #          _get_link      => [ get => 'link' ],
    #          _get_title     => [ get => 'title' ],
    #          updated        => [ get => 'updated' ],
    #    }
    #);
    #
    #method _build__storage_values {
    #    # todo check if load returns hash ref or undef
    #    return $self->load( uuid => $self->uuid ) || {};
    #}

}
