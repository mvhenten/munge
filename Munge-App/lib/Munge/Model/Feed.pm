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

use Munge::Types qw|UUID Uri ParserItem Account|;

class Munge::Model::Feed {
    use Data::Dumper;
    use DateTime;
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::FeedItem;
    use Munge::Model::Feed::Parser;
    use MooseX::StrictConstructor;
    use Munge::Types qw|UUID|;
    use Munge::UUID;

    with 'Munge::Role::Schema';

    has link => (
        is       => 'ro',
        isa      => 'Str',
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

    has blacklist => (
        is     => 'ro',
        isa    => 'Bool',
        writer => 'set_blacklist',
        default => 0,
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

    has synchronized => (
        is  => 'ro',
        isa => 'Maybe[DateTime]',
        writer => '_set_synchronized',
        default => sub {
            return DateTime->now;
        },
    );

    has updated => (
        is  => 'ro',
        isa => 'Maybe[DateTime]',
    );

    has created => (
        is  => 'ro',
        isa => 'Maybe[DateTime]',
    );

    method _get_synchronized_timestamp {
        my $dtf = $self->schema->storage->datetime_parser;

        if ( $self->synchronized ) {
            return $dtf->format_datetime( $self->synchronized );
        }
    }

    method store {
        my @keys = grep { defined $self->$_ } qw|blacklist uuid description link title|;
        my %values = map { $_ => $self->$_ } @keys;

        $values{synchronized} = $self->_get_synchronized_timestamp;

        if ( $self->created ) {
            my $row = $self->resultset('Feed')
                ->search_rs( { uuid => $self->uuid } )
                ->update( \%values );

            return $self;
        }

        Munge::Schema::Connection->schema()->resultset('Feed')->create({
            %values,
            link    => $self->link,
            uuid    => $self->uuid,
            created => DateTime->now,
        });

        return  Munge::Model::Feed->load( $self->uuid );
    }

    method create( $class : Uri $link ) {
        my $uuid = Munge::UUID->new( uri => $link )->uuid_bin;

        my $feed = Munge::Model::Feed->new(
            link => $link->as_string,
            uuid => $uuid
        );

        return $feed->store();
    }

    method load( $class : UUID $uuid ) {
        my $row = Munge::Schema::Connection->schema()->resultset('Feed')->find({
            uuid => $uuid,
        });

        if ($row) {
            return $class->new( { $row->get_inflated_columns() } );
        }
    }

    method synchronize() {
        my $feed_client = $self->_get_feed_client();

        return 1 unless $feed_client->updated;
        return 1 unless $feed_client->success;

        my $feed_parser = $self->_get_feed_parser( $feed_client->content );
        $self->_set_synchronized( DateTime->now );

        if ( not $feed_parser->xml_feed ) {
            warn 'Cannot parse feed: ' . $self->link;
            return 0;
        }

        $self->_set_title( $feed_parser->title || '' );
        $self->_set_description( $feed_parser->description || '' );

        for my $item ( $feed_parser->items ) {
            my $feed_item = Munge::Model::FeedItem->synchronize( $self, $item );
        }


        return 1;
    }

    method _get_feed_client {
        my $uri = URI->new( $self->link );

        return Munge::Model::Feed::Client->new(
            feed_uri            => $uri,
            last_modified_since => $self->updated,
        );
    }

    method _get_feed_parser( Str $content ) {
        return Munge::Model::Feed::Parser->new( content => $content );
    }

}

1;
