use MooseX::Declare;

=head1 NAME

Munge::Model::Feed

=head1 DESCRIPTION

Domain model. 

=head1 SYNOPSIS

    # use factory method for instantiation
    my $feed = Munge::Model::Feed->create( $uri, $account );

    # use uuid to load.
    my $feed = Munge::Model::Feed->new(
        account => $account,
        uuid    => $uuid,
    );

    # note: loads from db
    $feed->syncrhonize();
    $feed->store();

=cut

use Munge::Types qw|Uri Account|;

class Munge::Model::Feed {
    use DateTime;
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::Feed::Parser;
    use Munge::Model::FeedItem;

    has uuid => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has link => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has title => (
        is          => 'ro',
        isa         => 'Str',
        writer      => '_set_title',
        lazy_build  => 1,
    );

    has description => (
        is          => 'ro',
        isa         => 'Str',
        writer      => '_set_description',
        lazy_build  => 1,
    );

    has _feed_uri => (
        is         => 'ro',
        isa        => 'URI',
        reader     => 'uri',
        lazy_build => 1,
    );

    has _feed_client => (
        is         => 'ro',
        isa        => 'Munge::Model::Feed::Client',
        lazy_build => 1,
    );

    has _feed_parser => (
        is         => 'ro',
        isa        => 'Munge::Model::Feed::Parser',
        lazy_build => 1,
    );

    has _feed_items => (
        is => 'ro',
        isa => 'ArrayRef[Munge::Model::FeedItem]',
        traits => ['Array'],
        default => sub { [] },
        handles => {
            _add_feed_item      => 'push',
            _has_feed_items     => 'is_empty',
            _clear_feed_items   => 'clear',
            _store_feed_items   => [ map => \&{ $_->store(); } ],
        },
    );

    has _storage_values => (
        is => 'ro',
        isa => 'HashRef',
        traits => ['Hash'],
        lazy_build => 1,
        handles => {
            _get_description => [ get => 'description' ],
              _get_id        => [ get => 'id' ],
              _get_link      => [ get => 'link' ],
              _get_title     => [ get => 'title' ],
              updated        => [ get => 'updated' ],
        }
    );

    method _buid__storage_values {
        # todo check if load returns hash ref or undef
        return $self->load( uuid => $self->uuid ) || {};
    }

    method _build_description {
        return $self->_get_description || '';
    }

    method _build_title {
        return $self->_get_title || '';
    }

    method _build_link {
        return $self->_get_link;
    }

    method _build__feed_uri {
        return URI->new( $self->link );
    }

    method _build__feed_parser {
        return Munge::Model::Feed::Parser->new(
            content => $self->_feed_client->content );
    }

    method _build__feed_client {
        return Munge::Model::Feed::Client->new(
            feed_uri            => $self->feed_uri,
            last_modified_since => $self->updated,
        );
    }

    method create ( Uri $link, Account $account ) {
        my $uuid = Munge::UUID->new( uri => $link )->uuid;
        return $self->new( link => $link->as_string, uuid => $uuid );
    }

    method synchronize () {
        return unless $self->_feed_client->updated;

        $self->_set_title( $self->_feed_parser->title );
        $self->_set_description( $self->_feed_parser->description || '' );
        $self->_clear_feed_items();

        for my $item ( $self->_feed_parser->items ) {
            my $feed_item = Munge::Model::FeedItem->new(
                account     => $self->account,
                feed        => $self,
                uuid        => $item->uuid_bin,
                link        => $item->link,
                title       => $item->title,
                description => $item->content,
            );

            $self->_add_feed_item( $feed_item );
        }
    }
}
