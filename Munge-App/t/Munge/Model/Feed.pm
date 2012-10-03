use MooseX::Declare;

use Munge::Types qw|Uri Account|;

class t::Munge::Model::Feed {
    use Data::Dumper;
    use Munge::Model::Feed;
    use Test::Sweet;
    use URI;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    method create_feed_rs( Uri $uri?, Account $account? ) {
        $uri ||= URI->new('http://example.com/feed');
        $account ||= $self->create_test_account;
        
        warn $uri;

        my $rs = $self->resultset('Feed')->create(
            {
                account_id => $account->id,
                created    => DateTime->now(),
                link       => $uri,
            }
        )->insert();

        return $rs;

    }

    test feed_new {
        my $rs = $self->create_feed_rs;

        lives_ok {
            my $feed = Munge::Model::Feed->new( feed_resultset => $rs );
        }
        'instantiates';
    }
    
    test feed_synchronize {
        my $uri = URI->new('file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml');

        my $rs   = $self->create_feed_rs( $uri );
        my $feed = Munge::Model::Feed->new( feed_resultset => $rs );
        
        is( $feed->updated, undef, 'Updated is not yet defined' );
        is( $feed->title, undef, 'Title is not yet set');
        is( $feed->description, undef, 'Description is not yet set');
        
        lives_ok {
            $feed->synchronize();
        }
        'feed syncs';
 
        is( $feed->title, 'Example Feed', 'Updated title' );
        is( $feed->description, '', 'FIXME find feed with description');
    }
}
