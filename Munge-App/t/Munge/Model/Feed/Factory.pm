use MooseX::Declare;

class t::Munge::Model::Feed::Factory {
    use Test::Sweet;
    use URI;
    use Munge::Model::Feed::Factory;
    use Munge::Model::Feed;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';

    test factory_create {
        my $uri = URI->new('http://example.com/feed');

        my $feed =
          Munge::Model::Feed::Factory->new( schema => $self->schema )->create(
            account => $self->create_test_account,
            link    => $uri,
          );

        isa_ok( $feed, 'Munge::Model::Feed', 'is a Munge::Model:Feed' );
    }

    test factory_load {
        my $uri = URI->new('http://example.com/feed');

        my $feed =
          Munge::Model::Feed::Factory->new( schema => $self->schema )->create(
            account => $self->create_test_account,
            link    => $uri,
          );

        my $loaded_feed =
          Munge::Model::Feed::Factory->new( schema => $self->schema )
          ->load( $feed->id );

        isa_ok( $feed, 'Munge::Model::Feed', 'is a Munge::Model:Feed' );

    }

}
