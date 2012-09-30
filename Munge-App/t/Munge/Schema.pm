use MooseX::Declare;
    use Munge::Schema;
    use Test::Sweet;

        use DBICx::TestDatabase;

class t::Munge::Schema {
    use Munge::Schema;
    use Test::Sweet;

        use DBICx::TestDatabase;

    has 'schema' => (
        is         => 'ro',
        isa        => 'Munge::Schema',
#        lazy_build => 1,
        default => sub {  return DBICx::TestDatabase->new('Munge::Schema'); },
#        handles    => ['resultset'],
    );

    method _build_schema {
        return DBICx::TestDatabase->connect('Munge::Schema');
    }

    test schema {
        my ( $row, $item_row );

        my $schema = $self->schema; #DBICx::TestDatabase->new('Munge::Schema');
        pass;
#        warn $self->schema;

        #lives_ok {
        #    $row = $self->resultset('Feed')->create(
        #        {
        #            guid        => 'abc',
        #            link        => 'abc',
        #            title       => 'test',
        #            description => 'test'
        #        }
        #    )->insert();
        #}
        #'insert Feed';

        #ok( $row->id, 'id got set' );
        #
        #lives_ok {
        #    $item_row = $self->resultset('FeedItem')->create(
        #        {
        #            guid        => 'abc',
        #            link        => 'abc',
        #            title       => 'test',
        #            description => 'test',
        #            feed_id     => $row->id,
        #        }
        #    )->insert();
        #}
        #'insert FeedItem';
    }

}
