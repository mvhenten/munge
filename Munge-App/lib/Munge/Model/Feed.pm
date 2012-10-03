use MooseX::Declare;

=head1 NAME

Munge::Model::Feed 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

class Munge::Model::Feed {
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::Feed::Parser;

    has feed_resultset => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Feed',
        required => 1,
        handles  => [
            qw|
              account_id
              created
              description
              id
              link
              title
              updated
              feed_items
              |
        ],
    );

    has feed_uri => (
        is         => 'ro',
        isa        => 'URI',
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

    has _item_x_bool => (
        traits     => ['Hash'],
        is         => 'ro',
        isa        => 'HashRef',
        lazy_build => 1,
        handles    => { _item_exists => 'exists' }
    );

    method _build_feed_uri {
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

    method _build__item_x_bool {
        my %lookup = map { $_->uuid => 1 } $self->feed_items;

        return \%lookup;
    }

    method synchronize {
        return unless $self->_feed_client->updated;

        for my $item ( $self->_feed_parser->items ) {
            if ( not $self->_item_exists( $item->uuid ) ) {
                $self->_create_item($item);
            }
        }

        $self->title( $self->_feed_parser->title );
        $self->description( $self->_feed_parser->description || '' );

        $self->feed_resultset->update();
    }

    method _create_item {
        warn 'creating item... NOT!';
    }

}
