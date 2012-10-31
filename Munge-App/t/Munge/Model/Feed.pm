use MooseX::Declare;

use Munge::Types qw|Uri Account|;

class t::Munge::Model::Feed {
    use Data::Dumper;
    use Munge::Model::Feed;
    use Test::Sweet;
    use URI;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    #method create_feed_rs( Uri $uri?, Account $account? ) {
    #    $uri ||= URI->new('http://example.com/feed');
    #    $account ||= $self->create_test_account;
    #
    #    my $rs = $self->resultset('Feed')->create(
    #        {
    #            account_id => $account->id,
    #            created    => DateTime->now(),
    #            link       => $uri,
    #        }
    #    )->insert();
    #
    #    return $rs;
    #
    #}

    test feed_create {
#        my $rs = $self->create_feed_rs;

        my $uri  = URI->new('file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml');
        my $account = $self->create_test_account;

        my $feed;

        lives_ok {
            $feed = Munge::Model::Feed->create( $uri, $account );
        }
        'create lives';

        isa_ok( $feed, 'Munge::Model::Feed', '$feed');

#        $feed->synchronize();
    }

    #test feed_synchronize {
    #    my $uri  = URI->new('file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml');
    #    my $rs   = $self->create_feed_rs( $uri );
    #    my $feed = Munge::Model::Feed->new( feed_resultset => $rs );
    #
    #    is( $feed->updated, undef, 'Updated is not yet defined' );
    #    is( $feed->title, undef, 'Title is not yet set');
    #    is( $feed->description, undef, 'Description is not yet set');
    #    is_deeply( [$feed->feed_items], [], 'items is empty array' );
    #
    #    lives_ok {
    #        $feed->synchronize();
    #    }
    #    'feed syncs';
    #
    #    is( $feed->title, 'Example Feed', 'Updated title' );
    #    is( $feed->description, '', 'FIXME find feed with description');
    #
    #    my @items = $feed->feed_items;
    #
    #    for my $item ( @items ){
    #        is( $item->title, 'Atom-Powered Robots Run Amok', 'got proper title');
    #        is( $item->description, 'Some text.', 'got proper description');
    #    }
    #
    #    lives_ok {
    #        $feed->synchronize();
    #    }
    #    'feed syncs yet another time';
    #
    #    is_deeply( \@items, [$feed->feed_items], 'No new items were created' );
    #}
}
