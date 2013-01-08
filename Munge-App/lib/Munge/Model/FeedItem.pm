use MooseX::Declare;

=head1 NAME

 Munge::Model::FeedItem
 
=head1 DESCRIPTION

CRUD model for Feed items, uses "Storage" for load and delete.

=head1 SYNOPSIS

    # factory
    my $feed_item = Munge::Model::FeedItem->load( $uuid, $account );

    # constructor N.B. store requires all non-maybe attributes to
    # be set...
    
    my $feed_item = Munge::Model::FeedItem->new(
        account => $self->account,
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

    use DateTime;
    use Munge::Types qw|UUID Account ParserItem|;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';
    with 'Munge::Role::Storage';

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

    has id => (
        is     => 'ro',
        isa    => 'Int',
        writer => '_set_id',
    );

    has uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has link => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has feed_id => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
    );

    has read => (
        traits  => ['Bool'],
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        handles => {
            set_read   => 'set',
            set_unread => 'unset',
        }
    );

    has starred => (
        traits  => ['Bool'],
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        handles => {
            set_star    => 'set',
            unset_star  => 'unset',
            toggle_star => 'toggle',
        }
    );

    has created => (
        is         => 'ro',
        isa        => 'DateTime',
        lazy_build => 1
    );

    has modified => (
        is         => 'ro',
        isa        => 'DateTime',
        writer => '_set_modified',
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

    sub _build_created {
        return DateTime->now();
    }

    sub _build_modified {
        return DateTime->now();
    }

    sub _build_issued {
        return DateTime->today();
    }

    method synchronize( $class: Feed $feed, ParserItem $parser_item ) {
        my $feed_item =
          Munge::Model::FeedItem->load( $parser_item->uuid_bin, $feed->account );

          if ( not $feed_item ) {
            $feed_item = Munge::Model::FeedItem->new(
                account => $feed->account,
                feed_id => $feed->id,
                uuid    => $parser_item->uuid_bin,
                link    => $parser_item->link,
            );
        }

        for my $attr ( MUTABLE_ATTRIBUTES() ){
            my $setter = "_set_$attr";
              $feed_item->$setter( $parser_item->$attr );
          }
        
        return $feed_item;
    };
}
