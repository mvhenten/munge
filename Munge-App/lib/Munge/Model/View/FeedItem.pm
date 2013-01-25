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
    use DateTime::Format::MySQL;
    use Munge::Util qw|human_date_string find_interesting_image_source|;

sub FEED_ITEM_QUERY {
    my $sql = <<'SQL'
    SELECT
        fi.*,
        f.title AS feed_title,
        f.description AS feed_description,
        f.link AS feed_link,
        afi.`read`,
        afi.starred
    FROM feed_item fi
    LEFT JOIN feed f
        ON f.uuid = fi.feed_uuid
    LEFT JOIN account_feed_item afi
        ON afi.feed_item_uuid = fi.uuid
SQL
}

sub FEED_ITEM_ORDER_SQL {
    my $sql = <<'SQL'
    ORDER BY
        afi.`read` DESC,
        fi.issued DESC
SQL
}

    has account => (
        is => 'ro',
        isa => 'Munge::Schema::Result::Account',
        required => 1,
    );

    has _data_uuid => (
        is => 'ro',
        isa => 'Data::UUID',
        lazy_build => 1,
        handles => {
            uuid_to_string => 'to_string',
        }
    );

    method _build__data_uuid {
        return Data::UUID->new();
    }

    method format_datetime ( $dt ) {
        my $dtf = $self->schema->storage->datetime_parser;

        return $dtf->format_datetime( $dt );
    }

    method today {
        my $yesterday = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $today = $self->format_datetime( DateTime->today() );

        my $sql = FEED_ITEM_QUERY()
                . 'WHERE fi.created < ? AND afi.`read` = 0'
                . FEED_ITEM_ORDER_SQL();

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $yesterday
        );
    }

    method crunch {
        my $today = $self->format_datetime( DateTime->today() );

        my $sql = FEED_ITEM_QUERY()
                . 'WHERE fi.created < ? AND afi.`read` = 0'
                . FEED_ITEM_ORDER_SQL();

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $today
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method starred {
        my $sql = FEED_ITEM_QUERY() .
                'WHERE afi.starred = 1' . FEED_ITEM_ORDER_SQL();

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} },
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method list( UUID $feed_uuid, Int $page=1 ){
        my $sql = FEED_ITEM_QUERY() .
                'WHERE fi.feed_uuid = ?' . FEED_ITEM_ORDER_SQL();

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $feed_uuid
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method get_feed_item_data ( Str $item_uuid ) {
        my $sql = 'SELECT fi.*, f.title AS feed_title, f.description AS feed_description FROM feed_item fi LEFT JOIN feed f ON f.uuid = fi.feed_uuid WHERE fi.uuid = ? LIMIT 1';
        my $dbh = $self->schema->storage->dbh;

        my ( $item ) = @{ $dbh->selectall_arrayref( $sql,
            { Slice => {} }, to_UUID( $item_uuid )
        )};

        return $self->_create_list_view( $item );
    }

    method _create_list_view ( HashRef $item ) {

        my $poster_image = find_interesting_image_source( $item->{content}, $item->{feed_link} );
        my $issued_dt    = DateTime::Format::MySQL->parse_datetime( $item->{issued} );

        return {
            %{ $item },
            human_date          => human_date_string( $issued_dt  ),
            poster_image        => $poster_image || undef,
            feed_uuid_string => $self->uuid_to_string( $item->{feed_uuid} ),
            uuid_string => $self->uuid_to_string( $item->{uuid} ),
        };
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
        return $item ? $self->_old_create_list_view( $item ) : undef;
    }

    method _old_create_list_view ( $feed_item ) {
#        return {};
        my $ug = Data::UUID->new();

        my $issued = $feed_item->issued || DateTime->today;

        my %cols = $feed_item->get_inflated_columns();
#        my $feed = $feed_item->feed->description;

#        warn Dumper [ keys %cols ];

        return {};


        return {
            $feed_item->get_inflated_columns(),
            # human_date          => human_date_string( $issued ),
            date                => $issued->ymd,
#            poster_image        => find_interesting_image_source( $feed_item->content, $feed_item->feed->link ) || undef,
            #feed_description    => $feed_item->feed->description,
            #feed_title          => $feed_item->feed->title,
            #feed_uuid           => $feed_item->feed->uuid,
#            feed_uuid_string    => $ug->to_string( $feed_item->feed->uuid ),
            uuid_string         => $self->uuid_to_string( $feed_item->uuid ),
          }
    }


}
