use MooseX::Declare;

class t::Munge::Model::Feed {
    use Munge::Model::Feed;
    use Test::Sweet;
    use URI;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    method create_feed_rs {
        my $uri     = URI->new('http://example.com/feed');
        my $account = $self->create_test_account;

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
}
