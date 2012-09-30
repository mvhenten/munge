use MooseX::Declare;

class t::Munge::Schema {
    use Munge::Schema;
    use Test::Sweet;
    use DBICx::TestDatabase;

    has 'schema' => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    method _build_schema {
        return DBICx::TestDatabase->connect('Munge::Schema');
    }

    test test_schema {
        my ( $row, $item_row );

        lives_ok {
            $row = $self->resultset('Feed')->create(
                {
                    account_id  => 1,
                    link        => 'http://example.com/feed',
                    title       => 'abc',
                    description => 'abc',
                }
            )->insert();
        }
        'insert Feed';

        ok( $row->id, 'id got set' );

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
}
