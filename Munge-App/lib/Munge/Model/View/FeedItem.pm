use MooseX::Declare;
use MooseX::StrictConstructor;

=head1 NAME

Munge::Model::View::FeedItem

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Feed Account|;

class Munge::Model::View::FeedItem {

    with 'Munge::Role::Schema';

    use DateTime;
    use Munge::Types qw|UUID|;
    use Data::Dumper;
    use Munge::Util qw|human_date_string find_interesting_image_source|;

    has account => (
        is => 'ro',
        isa => 'Munge::Schema::Result::Account',
        required => 1,
    );

    method format_datetime ( $dt ) {
        my $dtf = $self->schema->storage->datetime_parser;

        return $dtf->format_datetime( $dt );
    }

    method today {
        my $yesterday = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                'account_feed_items.account_id' => $self->account->id,
                'me.created'    => { '>', $yesterday },
                'account_feed_items.read'       => 0,
            },
            {
                prefetch => [ 'feed', 'account_feed_items'],
                join => ['account_feed_items', 'feed' ],
                order_by   => { -desc => 'me.issued' },
                rows       => 40,        
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }
    
    method crunch {
        my $today = $self->format_datetime( DateTime->today() );

        my $items = $self->resultset('FeedItem')->search(
            {
                'account_feed_items.account_id' => $self->account->id,
                'me.created'    => { '<', $today },
                'account_feed_items.read'       => 0,
            },
            {
                prefetch => [ 'feed', 'account_feed_items'],
                join => ['account_feed_items', 'feed' ],
                order_by   => { -desc => 'me.issued' },
                rows       => 30,        
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method starred {
        my $items = $self->resultset('FeedItem')->search(
            {
                'account_feed_items.account_id' => $self->account->id,
                'account_feed_items.starred'       => 1,
            },
            {
                prefetch => [ 'feed', 'account_feed_items'],
                join => ['account_feed_items', 'feed' ],
                order_by   => { -desc => 'me.issued' },
                rows       => 30,        
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method list( Str $uuid, Int $page=1 ){
        my $items = $self->resultset('FeedItem')->search(
            {
                'account_feed_items.account_id' => $self->account->id,
                'me.feed_uuid' => to_UUID( $uuid ),
            },
            {
                prefetch => [ 'feed', 'account_feed_items'],
                join => ['account_feed_items', 'feed' ],
                order_by   => { -desc => 'me.issued' },
                rows       => 30,        
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method get_item( Str $uuid ){
        my $search = $self->resultset('FeedItem')->search(
            {
                'account_feed_items.account_id' => $self->account->id,
                'me.uuid' => to_UUID( $uuid ),
            },
            {
                prefetch => [ 'feed', 'account_feed_items'],
                join => ['account_feed_items', 'feed' ],
                #order_by   => { -desc => 'me.issued' },
                rows       => 1,        
            }
        );


        #my $search = $self->resultset('FeedItem')->search({
        #    'me.uuid' => to_UUID( $uuid ),
        #    'feed.account_id' => $self->account->id
        #},
        #{
        #    prefetch => 'feed',
        #    join => 'feed',
        #    order_by   => { -asc => 'me.issued' },
        #});

        my ( $item ) = $search->all();
        return $item ? $self->_create_list_view( $item ) : undef;
    }

    method _create_list_view ( $feed_item ) {
        my $ug = Data::UUID->new();

        my $issued = $feed_item->issued || DateTime->today;
        
        my %cols = $feed_item->get_inflated_columns();
        my $feed = $feed_item->feed->description;
        
#        warn Dumper [ keys %cols ];

        return {};


        return {
            $feed_item->get_inflated_columns(),
            human_date          => human_date_string( $issued ),
            date                => $issued->ymd,
            poster_image        => find_interesting_image_source( $feed_item->content, $feed_item->feed->link ) || undef,
            feed_description    => $feed_item->feed->description,
            feed_title          => $feed_item->feed->title,
            feed_uuid           => $feed_item->feed->uuid,
            feed_uuid_string    => $ug->to_string( $feed_item->feed->uuid ),
            uuid_string         => $ug->to_string( $feed_item->uuid ),
          }
    }


}
