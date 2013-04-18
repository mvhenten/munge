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
            SELECT f.title, f.uuid, COUNT( fi.uuid ) - SUM( afi.`read` ) AS unread
            FROM account_feed af
            LEFT JOIN feed f
                ON af.feed_uuid = f.uuid
            LEFT JOIN feed_item fi
                ON fi.feed_uuid = f.uuid
            LEFT JOIN account_feed_item afi
                ON afi.feed_item_uuid = fi.uuid
                AND afi.account_id = af.account_id
            WHERE af.account_id = ?
            GROUP BY af.feed_uuid
            ORDER BY unread DESC, f.title ASC
        ';

        my $dbh = $self->schema->storage->dbh;

        my $items = $dbh->selectall_arrayref( $sql,
            { Slice => {} },  $self->account->id
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
