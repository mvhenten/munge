use MooseX::Declare;

class t::Munge::Config {
    use Munge::Config;
    use Data::Dumper;
    use Test::Sweet;
    use Data::Validate::Email qw|is_email|;

    test basic {
        my $config;

        lives_ok {
            $config = Munge::Config::config();
        }
        'We can call config';

        is( ref $config, 'HASH', 'its a hashref' );
    }

    test app_email {
        ok( is_email( Munge::Config::APP_EMAIL() ),
            'App email is set, not empty, and looks like an email' );
    }

}
