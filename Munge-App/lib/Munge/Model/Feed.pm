use MooseX::Declare;
use MooseX::StrictConstructor;
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

use Munge::Types qw|UUID Uri Account|;

class Munge::Model::Feed {
    use DateTime;
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::FeedItem;
    use Munge::Model::Feed::Parser;
    use Munge::Types qw|UUID|;
    use Munge::UUID;

    with 'Munge::Role::Schema';
    with 'Munge::Role::DBICStorage' => { schema => 'Munge::Schema::Result::Feed' };

    has uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has link => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has title => (
        is          => 'ro',
        isa         => 'Maybe[Str]',
        writer      => '_set_title',
        lazy_build  => 1,
    );

    has description => (
        is          => 'ro',
        isa         => 'Maybe[Str]',
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
            feed_items          => 'elements',
            _add_feed_item      => 'push',
            _has_feed_items     => 'is_empty',
            _clear_feed_items   => 'clear',
#            _store_feed_items   => [ map => \&{ $_->store(); } ],
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

    method _build__storage_values {
        # todo check if load returns hash ref or undef
        return $self->load( uuid => $self->uuid ) || {};
    }

    method _build_description {
        return $self->_get_description || undef;
    }

    method _build_title {
        return $self->_get_title || undef;
    }

    method _build_link {
        my $link = $self->_get_link;

        if( not $link ){
            my $uuid = $self->uuid;
            confess( qq|Tried building link but failed, is UUID valid? $uuid| );
        }

        return $link;
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
            feed_uri            => $self->uri,
            last_modified_since => $self->updated,
        );
    }

    method create ( $class: Uri $link, Account $account ){
        my $uuid = Munge::UUID->new( uri => $link )->uuid_bin;
        return $class->new(
            link    => $link->as_string,
            uuid    => $uuid,
            account => $account,
        );
    }

    method synchronize () {
        return unless $self->_feed_client->updated;
        return unless $self->_feed_client->success;

        if( not $self->_feed_parser->xml_feed ){
            warn "Cannot parse feed: " . $self->uri;
            return;
        }


        $self->_set_title( $self->_feed_parser->title );
        $self->_set_description( $self->_feed_parser->description || '' );
        $self->_clear_feed_items();

        for my $item ( $self->_feed_parser->items ) {
            my $feed_item = Munge::Model::FeedItem->new(
                account     => $self->_account,
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
