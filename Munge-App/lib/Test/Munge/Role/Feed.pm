use MooseX::Declare;

use strict;
use warnings;

use Munge::Model::Feed;
use Munge::Types qw|UUID Uri Account|;

role Test::Munge::Role::Feed {

    use Cwd qw|realpath|;
    use URI;
    use Munge::Model::Feed;
    use Munge::Storage;
    use Munge::UUID;

    requires qw|create_test_account|;

    has feed_created_counts => (
        is => 'ro',
        isa => 'Int',
        traits => ['Counter'],
        default => sub { int( rand() * 100_000_000 ) },
        handles => {
            inc_feeds_created => 'inc',
        }
    );

    sub APPLICATION_PATH {
        my ($app_dir) = realpath(__FILE__) =~ m/(.+\/Munge-App\/)/;
        return $app_dir;
    }

    method create_test_feed_uri {
        my $filename = realpath(__FILE__);

        my $uri =
          URI->new( 'file:/' . APPLICATION_PATH() . '/t/resource/atom.xml?rand=' . $self->inc_feeds_created );

        return $uri;
    }

    method create_test_feed_with_items( ArrayRef $items, Account $account? ){
        my $feed = $self->create_test_feed( $account );

        foreach my $item_data ( @{ $items }  ) {
            $self->add_feed_item( $feed, %{ $item_data } );
        }

        return $feed;
    }

    method create_test_feed ( Account $account? ){
        $account ||= $self->create_test_account;

        my $uri     = URI->new( $self->create_test_feed_uri );
        $uri->query_form( q => rand % 99999 );

        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $storage = Munge::Storage->new(
            account     => $account,
            schema_name => Munge::Model::Feed->_schema_class(),
            schema      => $self->schema,
        );

        return Munge::Model::Feed->new(
            uuid     => $uuid,
            account  => $account,
            link     => $uri->as_string,
            _storage => $storage,
        );
    }


    method add_feed_item ( Munge::Model::Feed $feed, %item_data ) {
        my $storage = Munge::Storage->new(
            account     => $feed->account,
            schema_name => Munge::Model::FeedItem->_schema_class(),
            schema      => $self->schema,
        );

        my $uri     = URI->new( $self->create_test_feed_uri );
        $uri->query_form( q => rand % 99999 );
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        $item_data{feed_id} = $feed->id;
        $item_data{_storage} = $storage;

        my $feed_item = Munge::Model::FeedItem->new(
            title       => 'Test Feed Item Title ' . $feed->n_feed_items,
            description => 'Test Feed Item Description ' . $feed->n_feed_items,
            uuid        => $uuid,
            link        => $uri->as_string,
            read        => 0,
            starred     => 0,
            created     => DateTime->now(),
            %item_data,
        );

        $feed_item->store();
        $feed->_add_feed_item( $feed );
    }

    method _test_storage ( Account $account, $schema_name ) {
        my $storage = Munge::Storage->new(
            account     => $account,
            schema_name => $schema_name,
            schema      => $self->schema,``
        );
    }

}
