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
    use URI;

    use Munge::Util qw|uuid_string|;
    use Munge::Types qw|UUID|;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method all_feeds {
        my $sql = '
            SELECT COUNT(fi.feed_uuid) - afi.read_count AS unread, f.title, f.uuid
            FROM account_feed af
            LEFT JOIN feed f ON f.uuid = af.feed_uuid
            LEFT JOIN feed_item fi ON fi.feed_uuid = af.feed_uuid
            LEFT JOIN (
                SELECT feed_uuid, count(*) as read_count
                FROM account_feed_item
                WHERE account_id = ?
                GROUP BY feed_uuid
            ) afi ON afi.feed_uuid = fi.feed_uuid
            WHERE af.account_id = ?
            GROUP BY fi.feed_uuid
            ORDER BY unread DESC, f.title ASC
            LIMIT 50
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
            title       => $feed->{title} || $feed->{link},
            unread_items => $feed->{unread} || 0,
        }
    }
}
