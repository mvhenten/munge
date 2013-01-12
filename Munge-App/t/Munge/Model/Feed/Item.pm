use MooseX::Declare;

use Munge::Types qw|Feed|;

class t::Munge::Model::Feed::Item {

    use Munge::Model::Feed::Item;
    use Test::Sweet;
    use Munge::UUID;
    use Data::Dumper;
    
    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';
    with 'Test::Munge::Role::Feed';

    test create_feed_item {
        my $feed    = $self->create_test_feed;
        my $uri     = $self->create_test_feed_uri;
    
        $feed->store();
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;
    
        my $feed_item = Munge::Model::Feed::Item->new(
            account     => $feed->account,
            feed_id     => $feed->id,
            uuid        => $uuid,
            link        => $uri->as_string,
            title       => 'Title Test',
            description => 'Description Test',
            _storage    => $self->storage( $feed->account ),
        );
    
        lives_ok {
            $feed_item->store();
        }
        'feed item can be stored';
    }
    
    test load_existing {
        my $feed    = $self->create_test_feed;
        $feed->store();
            
        my $item = $self->create_test_feed_item( $feed );
        my $new_item;
        
        
        lives_ok {
            $new_item = Munge::Model::Feed::Item->load( $item->uuid, $feed->account, $self->storage( $feed->account ) );
        }
        'load lives with existing feedItem';
                
        isa_ok( $new_item, 'Munge::Model::Feed::Item', 'load returns an undef');
        
    }
    
    test load {
        my $feed    = $self->create_test_feed;
        my $uri     = $self->create_test_feed_uri;
    
        $feed->store();
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;
        
        my $item;
        
        lives_ok {
            $item = Munge::Model::Feed::Item->load( $uuid, $feed->account, $feed->_storage );
        }
        'load lives with non-existing feedItem';
        
        is( $item, undef, 'load returns an undef');
    }
    
    method create_test_feed_item ( Feed $feed ){
        my $uri     = $self->create_test_feed_uri;
        my $uuid    = Munge::UUID->new( uri => $uri )->uuid_bin;
        
        my $feed_item = Munge::Model::Feed::Item->new(
            account     => $feed->account,
            feed_id     => $feed->id,
            uuid        => $uuid,
            link        => $uri->as_string,
            title       => 'Title Test',
            description => 'Description Test',
            _storage    => $self->storage( $feed->account ),
        );
        
        $feed_item->store();
        return $feed_item;
    }
    
    method storage ( Account $account ){
        return $self->_test_storage( $account, Munge::Model::Feed::Item->_schema_class() );
    }
}
