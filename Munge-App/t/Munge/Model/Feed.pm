use MooseX::Declare;

class t::Munge::Model::Feed {

    use Data::Dumper;
    use Munge::Model::Feed;
    use Munge::Types qw|Uri Account UUID|;
    use Test::Sweet;
    use URI;
    use Sub::Override qw|sub_override|;
    use Munge::Storage;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';
    with 'Test::Munge::Role::Feed';

    test feed_create {
        my $account = $self->create_test_account;
        my $feed;

        my $uri = URI->new('http://example.com/atom.xml');

        lives_ok {
            $feed = Munge::Model::Feed->create( $uri, $account );
            $feed->store();
        }
        'create lives';
    }

    test feed_store {
        my $account = $self->create_test_account;
        my $uri     = URI->new( $self->create_test_feed_uri );
        my $uuid    = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $storage = Munge::Storage->new(
            account     => $account,
            schema_name => Munge::Model::Feed->_schema_class(),
            schema      => $self->schema,
        );

        my $feed = Munge::Model::Feed->new(
            uuid     => $uuid,
            account  => $account,
            link     => $uri->as_string,
            _storage => $storage,
        );

        lives_ok {
            $feed->store();
        }
        'store lives';

        ok( $self->resultset('Feed')->find( { uuid => $uuid } ),
            'Feed was stored' );
    }

    test load_by_uuid {
        my $feed = $self->create_test_feed;
        $feed->store();

        ok( $self->resultset('Feed')->find( { uuid => $feed->uuid } ),
            'Feed was stored' );

        my $loaded_feed = Munge::Model::Feed->load( $feed->uuid, $feed->account,
            $feed->_storage );

        isa_ok( $loaded_feed, 'Munge::Model::Feed' );
    }

    test feed_synchronize {
        my $override =
          Sub::Override->new( 'Munge::Model::Feed::Item::store' => sub { 1 } );

        my $feed = $self->create_test_feed;
        $feed->store();

        is( $feed->updated,     undef, 'Updated is not yet defined' );
        is( $feed->title,       undef, 'Title is not yet set' );
        is( $feed->description, undef, 'Description is not yet set' );

        lives_ok {
            $feed->synchronize();
        }
        'feed syncs';

        is( $feed->title, 'Example Feed', 'Updated title' );
        is( $feed->description, '', 'FIXME find feed with description' );

        # TODO test this somewhere
        #my @items = $feed->feed_items;
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
