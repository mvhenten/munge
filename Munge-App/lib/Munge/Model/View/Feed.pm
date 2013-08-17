use MooseX::Declare;
use MooseX::StrictConstructor;

=head1 NAME

Munge::Model::View::Feed

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|UUID Uri Account|;

class Munge::Model::View::Feed {
    use Data::Dumper;
    use Data::UUID;
    use DateTime;
    use List::Util qw|max|;
    use Munge::Types qw|UUID|;
    use Munge::Util qw|uuid_string|;
    use URI;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method all_feeds {
        my $sql = '
            SELECT f.uuid, f.title, f.description,
                COUNT(fi.feed_uuid) - COALESCE( items_read, 0) AS unread
            FROM account_feed af
            LEFT JOIN (
                SELECT feed_uuid, count(*) AS items_read
                FROM account_feed_item
                WHERE account_id = ?
                AND `read` = 1
                GROUP BY feed_uuid
            ) afi ON afi.feed_uuid = af.feed_uuid
            LEFT JOIN feed_item fi ON fi.feed_uuid = af.feed_uuid
            LEFT JOIN feed f ON f.uuid = af.feed_uuid
            WHERE af.account_id = ?
            GROUP BY fi.feed_uuid
            ORDER BY f.title ASC
        ';

        my $dbh = $self->schema->storage->dbh;

        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} },  $self->account->id, $self->account->id
        );
        return [ map { $self->_get_list_view( $_ ) } @{ $items } ];
    }

    method _get_list_view ( $feed ) {
        return {
            uuid_string => uuid_string( $feed->{uuid} ),
            title       => $feed->{title} || $feed->{link} || $feed->{description},
            unread_items => max( $feed->{unread} || 0, 0),
        }
    }
}
