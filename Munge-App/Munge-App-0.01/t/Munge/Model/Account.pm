use MooseX::Declare;

class t::Munge::Model::Account {
    use Crypt::SaltedHash;
    use Data::Dumper;
    use DateTime;
    use Munge::Model::Account;
    use MIME::Base64 qw|encode_base64 decode_base64|;
    use Test::Sweet;
    use Time::HiRes;
    use Time::HiRes qw|time gettimeofday|;
    use Math::Base36 qw|encode_base36|;

    with 'Test::Munge::Role::Schema';

    test account_create {
        my ($account);

        my $username = sprintf( 'user_%s@example.com',
            encode_base36( join( '', gettimeofday() ) ) );

        lives_ok {
            $account =
              Munge::Model::Account->new( schema => $self->schema )
              ->create( $username, 'password' );
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

    test acccount_find {
        my $username = sprintf( 'user_%s@example.com',
            encode_base36( join( '', gettimeofday() ) ) );

        my $account =
          Munge::Model::Account->new( schema => $self->schema )
          ->create( $username, 'password' );

        my $found_account =
          Munge::Model::Account->new( schema => $self->schema )
          ->find( { id => $account->id } );

        isa_ok(
            $found_account,
            'Munge::Schema::Result::Account',
            'load returned correct result'
        );

        is( $found_account->password, $account->password, 'data is the same' );

    }

    test account_verificate {
        my $username = sprintf( 'user_%s@example.com',
            encode_base36( join( '', gettimeofday() ) ) );

        my $password = $username;

        my $account = Munge::Model::Account->new( schema => $self->schema );

        $account->create( $username, $password );
        my $rs = $account->load($username);

        my $base64_salt = encode_base64( $rs->verification );
        ok( $account->verificate( $username, $password, $base64_salt ),
            'Verify returns ok' );

        my $verified_rs = $account->load($username);

        ok( $verified_rs->verified, 'Account was verified' );

    }

}
