use MooseX::Declare;

class t::Munge::Model::Feed {

    use Data::Dumper;
    use Munge::Model::Feed;
    use Munge::Types qw|Uri Account UUID|;
    use Test::Sweet;
    use URI;
    use Sub::Override qw|sub_override|;
    use Munge::Storage;

    use Cwd qw|realpath|;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    sub APPLICATION_PATH {
        my ($app_dir) = split( /\/t\//, realpath(__FILE__) );
        return $app_dir;
    }

    method create_test_feed_uri {
        my $filename = realpath(__FILE__);

        my $uri =
          URI->new( 'file:/' . APPLICATION_PATH() . '/t/resource/atom.xml' );
    }

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
            schema_name => Munge::Model::Feed::SCHEMA(),
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
        my $feed = $self->_test_feed;
        $feed->store();

        ok( $self->resultset('Feed')->find( { uuid => $feed->uuid } ),
            'Feed was stored' );

        #        return defined( $result ) ?  { $result->get_inflated_columns() } : {};

        #Sub::Override->new( 'Munge::Storage::new' => sub {
        #    warn 'in override';
        #    #return $self->schema->resultset( @_ );
        ##my ( $result ) = $self->resultset( 'Feed' )->find( { uuid => $feed->uuid, account_id => $feed->account->id } );
        ##
        ##warn Dumper({ $result->get_inflated_columns() });
        #
        #    #my %columns = $self->resultset('Feed')->find({
        #    #    uuid => $feed->uuid })->get_inflated_columns();
        #    #
        #    #warn Dumper( \%columns );
        #    #
        #    #return \%columns;
        #});

        Munge::Model::Feed->load( $feed->uuid, $feed->account,
            $feed->_storage );

        pass;
    }

    method _test_feed {
        my $account = $self->create_test_account;
        my $uri     = URI->new( $self->create_test_feed_uri );
        $uri->query_form( q => rand %99999 );

        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $storage = Munge::Storage->new(
            account     => $account,
            schema_name => Munge::Model::Feed::SCHEMA(),
            schema      => $self->schema,
        );

        return Munge::Model::Feed->new(
            uuid     => $uuid,
            account  => $account,
            link     => $uri->as_string,
            _storage => $storage,
        );
    }

    #
    #    test load_by_uuid {
    #        my $feed = $self->create_test_feed;
    #        $feed->store();
    #
##        warn Munge::Model::Feed->meta->schema;
    #
    #        my $loaded_feed = Munge::Model::Feed->load_by_uuid( $feed->uuid );
    #
    #        pass;
    #
    #    }
    #
    #    test feed_synchronize {
    #        pass;
    #        return;
    #        my $account = $self->create_test_account;
    #        my $uri  = $self->create_test_feed_uri;
    #
    #        my $feed = Munge::Model::Feed->create( $uri, $account );
    #
    #
##        my $feed = $self->create_test_feed();
    #        $feed->store();
    #
    #        is( $feed->updated, undef, 'Updated is not yet defined' );
    #        is( $feed->title, undef, 'Title is not yet set');
    #        is( $feed->description, undef, 'Description is not yet set');
    #        is_deeply( [$feed->feed_items], [], 'items is empty array' );
    #
    #        lives_ok {
    #            $feed->synchronize();
    #        }
    #        'feed syncs';
    #
    #        is( $feed->title, 'Example Feed', 'Updated title' );
    #        is( $feed->description, '', 'FIXME find feed with description');
    #
    #        my @items = $feed->feed_items;
    #
    #        #for my $item ( @items ){
    #        #    is( $item->title, 'Atom-Powered Robots Run Amok', 'got proper title');
    #        #    is( $item->description, 'Some text.', 'got proper description');
    #        #}
    #        #
    #        lives_ok {
    #            $feed->synchronize();
    #        }
    #        'feed syncs yet another time';
    #
    #        is_deeply( \@items, [$feed->feed_items], 'No new items were created' );
    #    }
}
