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

    #method feed_view ( $uuid ) {
    #    my ( $item ) = $self->resultset('Feed')->search({ uuid => to_UUID( $uuid ), account_id => $self->account->id });
    #
    #    return $self->_get_list_view( $item );
    #}

    method all_feeds {
        my $sql = '
            SELECT count(afi.`read`) AS unread, f.title, f.uuid
            FROM account_feed af
            RIGHT JOIN feed f
                ON af.feed_uuid = f.uuid
            LEFT JOIN (
                SELECT *
                FROM account_feed_item
                WHERE `read` = 0
            ) afi
                ON afi.account_id = af.account_id
                AND afi.feed_uuid = af.feed_uuid
            WHERE af.account_id = ?
            GROUP BY f.uuid
            ORDER BY unread DESC, f.title DESC
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
