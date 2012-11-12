use MooseX::Declare;

class t::Munge::Model::FeedItem {

    use Munge::Model::FeedItem;
    use Test::Sweet;
    use Munge::UUID;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';
    with 'Test::Munge::Role::Feed';

    test create_feed_item {
        my $account = $self->create_test_account;
        my $feed    = $self->create_test_feed;
        my $uri     = $self->create_test_feed_uri;

        $feed->store();
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $feed_item = Munge::Model::FeedItem->new(
            account     => $account,
            feed_id     => $feed->id,
            uuid        => $uuid,
            link        => $uri->as_string,
            title       => 'Title Test',
            description => 'Description Test',
            _storage    => $feed->_storage,
        );

        lives_ok {
            $feed_item->store();
        }
        'feed item can be stored';
    }
}
