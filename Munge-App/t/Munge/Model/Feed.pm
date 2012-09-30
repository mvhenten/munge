use MooseX::Declare;

class t::Munge::Model::Feed {
    use DBICx::TestDatabase;
    use Munge::Model::Feed;
    use Test::Sweet;

    has 'schema' => (
        is         => 'ro',
        isa        => 'Munge::Schema',
        lazy_build => 1,
        handles    => ['resultset'],
    );

    has account => (
        is         => 'ro',
        isa        => 'Munge::Schema::Result::Account',
        lazy_build => 1,
    );

    method _build_schema {
        return DBICx::TestDatabase->connect('Munge::Schema');
    }

    method _build_account {
        return $self->resultset('Account')->create(
            {
                email        => 'foo@example.com',
                password     => 'lskdjflaskj93023',
                verification => '',
                verified     => 1,
            }
        )->insert();
    }

    test feed_new {
        lives_ok {
            my $feed = Munge::Model::Feed->new( account => $self->account, );
        }
        'instantiates';

    }
}
