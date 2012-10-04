use MooseX::Declare;

class t::Munge::Schema {

    use Data::UUID qw|NameSpace_URL|;       
    use DBICx::TestDatabase;
    use Munge::Schema;
    use Test::Sweet;

    has 'schema' => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    with 'Test::Munge::Role::Account';
    
    method _build_schema {
        return DBICx::TestDatabase->connect('Munge::Schema');
    }

    test test_schema {
        my ( $account, $row, $item_row, $found_row );

        lives_ok {
            $account = $self->resultset('Account')->create(
                {
                    email        => 'foo@example.com',
                    password     => 'lskdjflaskj93023',
                    verification => '',
                    verified     => 1,
                }
            )->insert();
        }
        'insert Feed';

        lives_ok {
            $row = $self->resultset('Feed')->create(
                {
                    account_id  => $account->id,
                    link        => 'http://example.com/feed',
                    title       => 'abc',
                    description => 'abc',
                }
            )->insert();
        }
        'insert Feed';

        ok( $row->id, 'id got set' );

        lives_ok {
            $found_row = $self->resultset('Feed')->find( { id => $row->id } );
        }
        'insert Feed';

        is( $row->id, $found_row->id, 'id got set' );
        

        lives_ok {
            $item_row = $self->resultset('FeedItem')->create(
                {
                    account_id  => $row->account_id,
                    feed_id     => $row->id,
                    uuid        => 'abc',
                    link        => 'abc',
                    title       => 'abc',
                    description => 'abc',
                }
            )->insert();
        }
        'insert FeedItem';
    }
    
    method create_feed {
        my $account = $self->create_test_account();
        
        $feed = $self->resultset('Feed')->create(
            {
                account_id  => $account->id,
                link        => 'http://example.com/feed',
                title       => 'abc',
                description => 'abc',
            }
        )->insert();
    }

    test schema_feed_item {
        my ( $item_row, $feed );
        
        
        my $ug   = Data::UUID->new();
        my $uuid = $ug->create_str();

        my $insert_values = {
            account_id  => $feed->account_id,
            feed_id     => $feed->id,
            uuid        => $ug->from_string($uuid),
            link        => 'http://schema/feed/item/link',
            title       => 'Schema Feed Item Title',
            description => 'Schema Feed Item Desc',
          }
        
        lives_ok {
            $item_row = $self->resultset('FeedItem')->create( $insert_values )->insert();
        }
        'insert FeedItem';
        
        my $updated_rs = $self->resultset('FeedItem')->find( $item_row->id );
        
        
    }
}
