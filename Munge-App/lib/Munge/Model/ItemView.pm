use MooseX::Declare;

=head1 NAME

Munge::Model::ItemView 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Feed Account|;

class Munge::Model::ItemView {

    with 'Munge::Role::Schema';

    
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