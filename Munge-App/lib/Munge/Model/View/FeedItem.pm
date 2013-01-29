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
;
    return $sql;
}

sub FEED_ITEM_ORDER_SQL {
    my $sql = <<'SQL'
    ORDER BY
        afi.`read` ASC,
        fi.issued DESC
SQL
;
    return $sql;
}

sub FEED_ITEM_UNREAD_TODAY_SQL {
    my $sql = <<'SQL'
        SELECT
            fi.*,
            f.title AS feed_title,
            f.description AS feed_description,
            f.link AS feed_link,
            afi.`read`,
            afi.starred
        FROM feed_item fi
        LEFT JOIN feed f ON fi.feed_uuid = f.uuid
        LEFT JOIN account_feed af ON af.feed_uuid = fi.feed_uuid
        LEFT JOIN account_feed_item afi
            ON afi.feed_item_uuid = fi.uuid
            AND afi.account_id = af.account_id
        WHERE fi.issued > DATE_SUB( NOW(), INTERVAL 1 DAY )
        AND afi.`read` IS NULL OR afi.`read` = 0
        AND af.account_id = ?
        ORDER BY fi.issued DESC
        LIMIT 25
SQL
;
    return $sql;
}

sub FEED_ITEM_UNREAD_OLDER_THEN_TODAY {
    my $sql = <<'SQL'
        SELECT
            fi.*,
            f.title AS feed_title,
            f.description AS feed_description,
            f.link AS feed_link,
            afi.`read`,
            afi.starred
        FROM feed_item fi
        LEFT JOIN feed f ON fi.feed_uuid = f.uuid
        LEFT JOIN account_feed af ON af.feed_uuid = fi.feed_uuid
        LEFT JOIN account_feed_item afi
            ON afi.feed_item_uuid = fi.uuid
            AND afi.account_id = af.account_id
        WHERE fi.issued < DATE_SUB( NOW(), INTERVAL 1 DAY )
        AND afi.`read` IS NULL OR afi.`read` = 0
        AND af.account_id = ?
        ORDER BY fi.issued DESC
        LIMIT 25
SQL
;
    return $sql;
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
        my $sql = FEED_ITEM_UNREAD_TODAY_SQL();

        my $dbh = $self->schema->storage->dbh;

        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $self->account->id,
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method crunch {
        my $sql = FEED_ITEM_UNREAD_OLDER_THEN_TODAY();
        my $dbh = $self->schema->storage->dbh;

        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $self->account->id
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method starred {
        my $sql = $self->_wrap_sql( 'WHERE afi.starred = 1' );

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} },
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method list( UUID $feed_uuid, Int $page=1 ){
        my $sql = $self->_wrap_sql( 'WHERE fi.feed_uuid = ?' );

        my $dbh = $self->schema->storage->dbh;
        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} }, $feed_uuid
        );

        return [ map { $self->_create_list_view( $_ ) } @{$items} ];
    }

    method get_feed_item_data ( Str $item_uuid ) {
        my $sql = '
            SELECT
                fi.*,
                f.title  AS feed_title,
                f.description AS feed_description
            FROM feed_item fi
            LEFT JOIN feed f ON f.uuid = fi.feed_uuid
            WHERE fi.uuid = ?
            LIMIT 1
        ';

        my $dbh = $self->schema->storage->dbh;

        my ( $item ) = @{ $dbh->selectall_arrayref( $sql,
            { Slice => {} }, to_UUID( $item_uuid )
        )};

        return $self->_create_list_view( $item );
    }

    method _wrap_sql( Str $query ) {
        my $sql =
            FEED_ITEM_QUERY() . $query .
            FEED_ITEM_ORDER_SQL()
            . 'LIMIT 25 OFFSET 0' # TODO FIXME MAKE PAGER
            ;

        return $sql;
    }

    method _create_list_view ( HashRef $item ) {

        my $poster_image = find_interesting_image_source( $item->{content}, $item->{feed_link} );
        my $issued_dt    = DateTime::Format::MySQL->parse_datetime( $item->{issued} );

        return {
            %{ $item },
            human_date          => human_date_string( $issued_dt  ),
            feed_uuid_string => $self->uuid_to_string( $item->{feed_uuid} ),
            uuid_string => $self->uuid_to_string( $item->{uuid} ),
        };
    }
}
