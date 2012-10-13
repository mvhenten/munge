use MooseX::Declare;

=head1 NAME

Munge::Model::ItemView 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Feed Account|;

class Munge::Model::ItemView {

    with 'Munge::Role::Schema';
    use DateTime;
    
    has account => (
        is => 'ro',
        isa => 'Munge::Schema::Result::Account',
        required => 1,
    );
    
    method today {
        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '>=', DateTime->today()->subtract('days' => 1) },
            },
            {
                order_by   => { -asc => 'created' },
                rows       => 10,
            }
        );
        
        return [ $items->all() ];
    }

    method yesterday {
        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '>=', DateTime->today()->subtract('days' => 2) },
                created    => { '<=', DateTime->today()->subtract('days' => 1) },
            },
            {
                order_by   => { -asc => 'created' },
                rows       => 10,
            }
        );
        
        return [ $items->all() ];
    }

    method older {
        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '<=', DateTime->today()->subtract('days' => 2) },
            },
            {
                order_by   => { -asc => 'created' },
                rows       => 25,
            }
        );
        
        return [ $items->all() ];
    }

    
    method list_account( Account $account, Int $page=1 ){
        my $items = $self->resultset('FeedItem')->search(
            { account_id => $account->id },
            {
                order_by   => { -asc => 'created' },
                page       => $page,
                rows       => 25,
            }
        );
        
        return [ $items->all() ];
    }
    
    method list_feed( Feed $feed, Int $page=1 ){
        my $items = $self->resultset('FeedItem')->search(
            { feed_id => $feed->id },
            {
                order_by   => { -asc => 'created' },
                page       => $page,
                rows       => 25,
            }
        );
        
        return $items->all();
    }
    

}