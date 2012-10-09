use MooseX::Declare;

class t::Munge::Model::Account {
    use Crypt::SaltedHash;
    use Data::Dumper;
    use DateTime;
    use Munge::Model::Account;
    use Test::Sweet;
    use Time::HiRes;
    use Time::HiRes qw|time gettimeofday|;
    use Math::Base36 'encode_base36';

    with 'Test::Munge::Role::Schema';

    test account_create {
        my ($account);

        lives_ok {
            $account =
              Munge::Model::Account->new( schema => $self->schema )
              ->create( 'usernane', 'password' );
        }
        'Created ok';

        isa_ok(
            $account,
            'Munge::Schema::Result::Account',
            'create returned correct result'
        );
    }

    test account_load {
        my ( $account, $found_account );

        my $username = sprintf( 'user_%s@example.com',
            encode_base36( join( '', gettimeofday() ) ) );

        $account = Munge::Model::Account->new( schema => $self->schema );
        my $account_rs = $account->create( $username, 'password' );

        lives_ok {
            $found_account = $account->load($username);
        }
        'Found ok';

        isa_ok(
            $found_account,
            'Munge::Schema::Result::Account',
            'load returned correct result'
        );

        is( $found_account->password, $account_rs->password,
            'data is the same' );

    }

    test account_validate {
        my ( $account, $valid );

        my $username = sprintf( 'user_%s@example.com',
            encode_base36( join( '', gettimeofday() ) ) );
        my $password = $username;

        $account =
          Munge::Model::Account->new( schema => $self->schema )
          ->create( $username, $password );

        lives_ok {
            $valid =
              Munge::Model::Account->new( schema => $self->schema )
              ->validate( $account, $password );
        }
        'Validate lives ok';

        ok( $valid, 'Validate returns true' );

        lives_ok {
            $valid =
              Munge::Model::Account->new( schema => $self->schema )
              ->validate( $account, 'bogus' );
        }
        'Validate lives ok';

        ok( ( not $valid ), 'Validate returns false' );
    }

}
