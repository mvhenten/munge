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
    
    method format_datetime ( $dt ) {
        my $dtf = $self->schema->storage->datetime_parser;
        
        return $dtf->format_datetime( $dt );
    }
    
    method today {
        my $yesterday = $self->format_datetime( DateTime->today()->subtract('days' => 1) );
    
        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '>=', $yesterday },
            },
            {
                order_by   => { -asc => 'created' },
                rows       => 10,
            }
        );
        
        return [ $items->all() ];
    }

    method yesterday {
        my $min_age = $self->format_datetime( DateTime->today()->subtract('days' => 2) );
        my $max_age = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '>=', $min_age },
                created    => { '<=', $max_age },
            },
            {
                order_by   => { -asc => 'created' },
                rows       => 10,
            }
        );
        
        return [ $items->all() ];
    }

    method older {
        my $max_age = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                account_id => $self->account->id,
                created    => { '<=', $max_age },
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