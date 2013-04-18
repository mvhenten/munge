use MooseX::Declare;
use MooseX::StrictConstructor;

=head1 NAME

 Munge::Model::Feed::ItemCollection

=head1 DESCRIPTION

This class performs actions on all items of a feed at once, like marking items read/unread.
I'm struggling with this: best thing to describe this is "Command Query Responsibility Segregation"

=head1 SYNOPSIS

    my $collection = Munge::Model::Feed::ItemCollection->new(
        feed    => $feed,
        account => $account
    );

    # perform bulk action read
    $collection->read(1);

=cut

class Munge::Model::Feed::ItemCollection {

    has feed => (
        is       => 'ro',
        isa      => 'Munge::Model::Feed',
        required => 1,
    );

    # TODO I've decided to forgo
    # on using DBIC class for some of these queries.
    # AFAIK this is more effective ( two queries ) for a bulk update
    # and more readable written as SQL. What to do? move all queries
    # into one sql library?
    sub UPDATE_ACCOUNT_FEED_ITEM_READ {
        return '
            UPDATE account_feed_item
            SET `read` = ?
            WHERE feed_uuid = ?
            AND account_id = ?
        ';
    }

    sub CREATE_ACCOUNT_FEED_ROWS_FOR_FEED_ITEMS {
        return '
            INSERT INTO account_feed_item ( account_id, feed_uuid, feed_item_uuid )
            SELECT ? AS account_id, fi.feed_uuid, fi.uuid
            FROM  feed_item fi
                LEFT JOIN account_feed_item afi
                ON afi.feed_item_uuid = fi.uuid
                AND afi.account_id = ?
            WHERE fi.feed_uuid = ?
            AND afi.feed_uuid IS NULL
        ';
    }

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method read( Bool $is_read ) {
        $self->dbh->do( CREATE_ACCOUNT_FEED_ROWS_FOR_FEED_ITEMS(),
            {}, $self->account->id, $self->account->id, $self->feed->uuid );

        $self->dbh->do( UPDATE_ACCOUNT_FEED_ITEM_READ(),
            {}, $is_read, $self->feed->uuid, $self->account->id );
    };
}
