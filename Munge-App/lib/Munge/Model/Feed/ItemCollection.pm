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

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method read( Bool $is_read ) {
        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                feed_id    => $self->feed->id
            }
        );

        $items->update( { read => $is_read } );
    };
}
