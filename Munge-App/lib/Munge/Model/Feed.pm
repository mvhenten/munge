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
    use Data::Dumper;
    use DateTime;
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::FeedItem;
    use Munge::Model::Feed::Parser;
    use Munge::Types qw|UUID|;
    use Munge::UUID;
    use Munge::Storage;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';
    with 'Munge::Role::Storage';

    has link => (
        is => 'ro',
        isa => 'Str',
        required => 1,
    );

    has uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has description => (
        is     => 'ro',
        isa    => 'Str',
        writer => '_set_description',
    );

    has id => (
        is     => 'ro',
        isa    => 'Int',
        writer => '_set_id',
    );

    has link => (
        is     => 'ro',
        isa    => 'Str',
        writer => '_set_link',
    );

    has title => (
        is     => 'ro',
        isa    => 'Str',
        writer => '_set_title',
    );

    has updated => (
        is     => 'ro',
        isa    => 'Maybe[DateTime]',
        writer => '_set_updated',
    );

    has created => (
        is     => 'ro',
        isa    => 'Maybe[DateTime]',
        writer => '_set_created',
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
        },
    );


    method _build_created {
        return DateTime->now();
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
        my $feed_client = $self->_get_feed_client();

        return unless $feed_client->updated;
        return unless $feed_client->success;

        confess( 'Must store feed before calling synchronize' ) unless $self->id;

        my $feed_parser = $self->_get_feed_parser( $feed_client->content );

        if( not $feed_parser->xml_feed ){
            warn 'Cannot parse feed: ' . $self->uri;
            return;
        }

        $self->_set_title( $feed_parser->title );
        $self->_set_description( $feed_parser->description || '' );
        $self->_clear_feed_items();

        for my $item ( $feed_parser->items ) {
            my $feed_item = Munge::Model::FeedItem->new(
                account     => $self->account,
                description => $item->content,
                feed_id     => $self->id,
                link        => $item->link,
                title       => $item->title,
                uuid        => $item->uuid_bin,
            );

            $feed_item->store();

            $self->_add_feed_item( $feed_item );
        }
    }

    method _get_feed_client {
        my $uri = URI->new( $self->link );

        return Munge::Model::Feed::Client->new(
            feed_uri            => $uri,
            last_modified_since => $self->updated,
        );
    }

    method _get_feed_parser ( Str $content ) {
        return Munge::Model::Feed::Parser->new(
            content => $content );
    }

}
