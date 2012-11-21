use MooseX::Declare;

class Munge::Model::FeedItem {

    use Munge::Types qw|UUID|;
    use DateTime;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';
    with 'Munge::Role::Storage';

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
        traits  => ['Bool'],
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        handles => {
            set_read    => 'set',
            set_unread  => 'unset',
        }
    );

    has starred => (
        traits  => ['Bool'],
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        handles => {
            set_star    => 'set',
            unset_star      => 'unset',
            toggle_star     => 'toggle',
        }
    );

    has created => (
        is         => 'ro',
        isa        => 'DateTime',
        lazy_build => 1
    );

    sub _build_created {
        return DateTime->now();
    }
}
