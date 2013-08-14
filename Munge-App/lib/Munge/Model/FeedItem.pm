use MooseX::Declare;

=head1 NAME

 Munge::Model::FeedItem

=head1 DESCRIPTION

CRUD model for Feed items, uses "Storage" for load and delete.

=head1 SYNOPSIS

    # factory
    my $feed_item = Munge::Model::FeedItem->load( $uuid );

    # constructor N.B. store requires all non-maybe attributes to
    # be set...

    my $feed_item = Munge::Model::FeedItem->new(
        feed_id => $feed->id,
        uuid    => $item->uuid_bin,
        link    => $item->link,
        ...
    );

    # sync with a ParserItem only updates MUTABLE_ATTRIBUTES

     Munge::Model::FeedItem->synchronize( $feed, $parser_item );

=ITEM MUTABLE_ATTRIBUTES

non-required constructor arguments that may be updated by synchronize
and that have a (private) _setter

    author
    content
    modified
    summary
    tags
    title

=cut

#use Munge::Types qw|UUID Account Feed ParserItem|;

class Munge::Model::FeedItem {

    use Data::Dumper;
    use DateTime;
    use Munge::Types qw|UUID ParserItem|;
    use Munge::Util qw|find_interesting_image_source|;

    with 'Munge::Role::Schema';

    sub MUTABLE_ATTRIBUTES {
        return qw|
          author
          content
          modified
          summary
          tags
          title
          |;
    }

    has uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has feed_uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has link => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has created => (
        is         => 'ro',
        isa        => 'DateTime',
    );

    has modified => (
        is         => 'ro',
        isa        => 'Maybe[DateTime]',
        writer     => '_set_modified',
        lazy_build => 1
    );

    has author => (
        is     => 'ro',
        isa    => 'Maybe[Str]',
        writer => '_set_author',
    );

    has title => (
        is     => 'ro',
        isa    => 'Str',
        writer => '_set_title',
    );

    has poster_image => (
        is          => 'ro',
        isa         => 'Maybe[Str]',
        writer      => '_set_poster_image',
        clearer     => '_clear_poster_image',
        lazy_build  => 1,
    );

    has content => (
        is     => 'ro',
        isa    => 'Maybe[Str]',
        writer => '_set_content',
    );

    has issued => (
        is     => 'ro',
        isa    => 'Maybe[DateTime]',
        writer => '_set_issued',
        lazy_build => 1
    );

    has tags => (
        is     => 'ro',
        isa    => 'Maybe[Str]',
        writer => '_set_tags',
    );

    has summary => (
        is     => 'ro',
        isa    => 'Maybe[Str]',
        writer => '_set_summary',
    );

    sub _build_modified {
        return DateTime->now();
    }

    sub _build_issued {
        return DateTime->today();
    }

    method _build_poster_image {
        return find_interesting_image_source( $self->content ) || '';
    }

    method store {
        my %values = map { $_ => $self->$_ || '' } MUTABLE_ATTRIBUTES();

        $values{modified}       = $self->_format_datetime( $self->modified );
        $values{issued}         = $self->_format_datetime( $self->issued );
        $values{poster_image}   = $self->poster_image;

        warn $values{poster_image};

        if ( $self->created ) {
            my $row = $self->resultset('FeedItem')
                ->search_rs( { uuid => $self->uuid } )
                ->update( \%values );

            return $self;
        }

        $self->resultset('FeedItem')->create({
            %values,
            feed_uuid   => $self->feed_uuid,
            uuid        => $self->uuid,
            created     => DateTime->now,
            link        => $self->link,
        });

        return Munge::Model::FeedItem->load( $self->uuid );
    }

    method load( $class : UUID $uuid ) {
        my $row = Munge::Schema::Connection->schema()->resultset('FeedItem')->find({
            uuid => $uuid,
        });

        if ($row) {
            return $class->new( { $row->get_inflated_columns() } );
        }
    }

    method synchronize( $class: Feed $feed, ParserItem $parser_item ) {
        my $feed_item =
          Munge::Model::FeedItem->load( $parser_item->uuid_bin );

        return if $feed_item;
        return if not $parser_item->link;

        my @keys = grep { defined $parser_item->$_ } MUTABLE_ATTRIBUTES();
        my %values = map { $_ => $parser_item->$_ } @keys;

        $feed_item = Munge::Model::FeedItem->new(
            %values,
            uuid        => $parser_item->uuid_bin,
            feed_uuid   => $feed->uuid,
            link        => $parser_item->link,
        );

        $feed_item->store();

        return;
    }
}
