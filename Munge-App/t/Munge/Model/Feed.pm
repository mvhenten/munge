use MooseX::Declare;

class t::Munge::Model::Feed {

    use Data::Dumper;
    use Munge::Model::Feed;
    use Munge::Types qw|Uri Account UUID|;
    use Test::Sweet;
    use URI;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    method create_feed_rs( $uri?, $account? ) {
        $uri ||= URI->new('http://example.com/feed');
        $account ||= $self->create_test_account;

        my $rs = $self->resultset('Feed')->create(
            {
                account_id => $account->id,
                created    => DateTime->now(),
                link       => $uri,
            }
        )->insert();

        return $rs;

    }

    test feed_create {
        my $account = $self->create_test_account;
        my $feed;

        my $uri = URI->new(
            'file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml'
        );

        lives_ok {
            $feed = Munge::Model::Feed->create( $uri, $account );
        }
        'create lives';

        isa_ok( $feed, 'Munge::Model::Feed', '$feed' );
    }

    test feed_store {
        my $uri = URI->new(
            'file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml'
        );

        my $account = $self->create_test_account;
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $feed = Munge::Model::Feed->new(
            link    => $uri->as_string,
            uuid    => $uuid,
            account => $account,
            schema  => $self->schema,
        );

        # NB still failing need to update schema config.
        $feed->store();

        pass;

    }

    method create_test_feed {
        my $account = $self->create_test_account;
        my $uri = URI->new(
            'file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml'
        );

        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $feed = Munge::Model::Feed->new(
            link    => $uri->as_string,
            uuid    => $uuid,
            account => $account,
            schema  => $self->schema,
        );

        return $feed;
    }

    test feed_synchronize {
        my $feed = $self->create_test_feed();
        $feed->store();

        pass;


        #my $uri  = URI->new('file://home/matthijs/Development/Munge/Munge-App/t/resource/atom.xml');
        #my $rs   = $self->create_feed_rs( $uri );
        #my $feed = Munge::Model::Feed->new( feed_resultset => $rs );
        #
        #is( $feed->updated, undef, 'Updated is not yet defined' );
        #is( $feed->title, undef, 'Title is not yet set');
        #is( $feed->description, undef, 'Description is not yet set');
        #is_deeply( [$feed->feed_items], [], 'items is empty array' );
        #
        #lives_ok {
        #    $feed->synchronize();
        #}
        #'feed syncs';
        #
        #is( $feed->title, 'Example Feed', 'Updated title' );
        #is( $feed->description, '', 'FIXME find feed with description');
        #
        #my @items = $feed->feed_items;
        #
        #for my $item ( @items ){
        #    is( $item->title, 'Atom-Powered Robots Run Amok', 'got proper title');
        #    is( $item->description, 'Some text.', 'got proper description');
        #}
        #
        #lives_ok {
        #    $feed->synchronize();
        #}
        #'feed syncs yet another time';
        #
        #is_deeply( \@items, [$feed->feed_items], 'No new items were created' );
    }
}
