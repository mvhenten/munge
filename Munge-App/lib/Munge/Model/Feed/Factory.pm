use MooseX::Declare;

use Munge::Types qw|Uri Account|;

class Munge::Model::Feed::Factory {
    use Munge::Model::Feed;
    use DateTime;
    
    with 'Munge::Role::Schema';
    
    method create( Account :$account, Uri :$link ) {
        my $rs = $self->resultset('Feed')->create(
            {
                account_id  => $account->id,
                created     => DateTime->now(),
                link        => $link,
            }
        )->insert();
        
        return Munge::Model::Feed->new( feed_resultset => $rs );
    }
    
    method load( Int $id ){
        my ( $rs ) = $self->resultset('Feed')->search({ id => $id });
        
        return Munge::Model::Feed->new( feed_resultset => $rs );
    }
    
    method list( Int $account_id ){
        my @rows = $self->resultset('Feed')->search({ account_id => $account_id });
        
        return @rows;
    }
}
