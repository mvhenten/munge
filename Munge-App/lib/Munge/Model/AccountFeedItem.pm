use MooseX::Declare;

=head1 NAME

 Munge::Model::FeedItem

=head1 DESCRIPTION

TODO

=head1 SYNOPSIS

TODO

=cut

use Munge::Types qw|UUID Account|;


class Munge::Model::AccountFeedItem {

    use Munge::Types qw|UUID|;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';
    
    has feed_uuid => (
        is       => 'ro',
        isa      => UUID,
        required => 1,
    );

    has feed_item_uuid => (
        is       => 'ro',
        isa      => UUID,
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
    
    method find( $class: UUID $uuid, Account $account ) {
        my $row = Munge::Schema::Connection->schema()->resultset('AccountFeedItem')->find({
            feed_item_uuid => $uuid,
            account_id     => $account->id,
        });
        
        if( $row ) {
            my %arguments = (
                 $row->get_columns(),
                feed_item_uuid => $uuid,
                account         => $account,
            );
            
            return $class->new( %arguments );                        
        }
    }
        
    method store {
        my $row = $self->resultset('AccountFeedItem')->update_or_create({
            'feed_item_uuid' => $self->feed_item_uuid,
            'feed_uuid'     => $self->feed_uuid,
            'account_id'     => $self->account->id,
            starred => $self->starred,
            read    => $self->read,
        });

        return; 
    }
    
}
