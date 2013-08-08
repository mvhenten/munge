use MooseX::Declare;

class t::Munge::Model::Feed {

    use Data::Dumper;
    use Munge::Model::Feed;
    use Munge::Types qw|Uri Account UUID|;
    use Test::Sweet;
    use URI;
    use Sub::Override qw|sub_override|;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';
    with 'Test::Munge::Role::Feed';

    method override_schema {
        my $override = Sub::Override->new( 'Munge::Schema::Connection::schema',
            sub { return $self->schema } );
    }

    test feed_create {
        my $override = $self->override_schema;

        my $feed;

        my $uri = URI->new( 'http://example.com/atom.xml?rand=' . rand() );
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        lives_ok {
            $feed = Munge::Model::Feed->create($uri);
        }
        'create lives';

        ok( $self->resultset('Feed')->find( { uuid => $uuid } ),
            'Feed was stored' );

    }

    #test feed_store {
    #    my $override = $self->override_schema;
    #
    #    my $uri = URI->new( $self->create_test_feed_uri );
    #    my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;
    #
    #    my $feed = Munge::Model::Feed->new(
    #        uuid => $uuid,
    #        link => $uri->as_string,
    #    );
    #
    #    $feed->store();
    #
    #    ok( $self->resultset('Feed')->find( { uuid => $uuid } ),
    #        'Feed was stored' );
    #}

    test load_by_uuid {
        my $feed = Munge::Model::Feed->create( $self->create_test_feed_uri );

        ok( $self->resultset('Feed')->search( { uuid => $feed->uuid } ),
            'Feed was stored' );

        my $loaded_feed = Munge::Model::Feed->load( $feed->uuid );

        isa_ok( $loaded_feed, 'Munge::Model::Feed' );
    }

    test feed_synchronize {
        my $override = $self->override_schema;

        my $feed = Munge::Model::Feed->create( $self->create_test_feed_uri );

        is( $feed->updated,     undef, 'Updated is not yet defined' );
        is( $feed->title,       '',    'Title is not yet set' );
        is( $feed->description, '',    'Description is not yet set' );

        lives_ok {
            $feed->synchronize();
        }
        'feed syncs';

        is( $feed->title, 'Example Feed', 'Updated title' );
        is( $feed->description, '', 'FIXME find feed with description' );

        $feed->store();

        is(
            $self->resultset('FeedItem')
              ->search( { feed_uuid => $feed->uuid } ),
            1,
            'Feed items were saved'
        );

        # TODO test this somewhere
        #        my @items = $feed->feed_items;

        #        warn Dumper \@items;
        #
        #for my $item (@items) {
        #    is(
        #        $item->title,
        #        'Atom-Powered Robots Run Amok',
        #        'got proper title'
        #    );
        #    is( $item->description, 'Some text.', 'got proper description' );
        #}
        #
        #lives_ok {
        #    $feed->synchronize();
        #}
        #'feed syncs yet another time';
        #
        #is_deeply( \@items, [ $feed->feed_items ],
        #    'No new items were created' );

    }

}
