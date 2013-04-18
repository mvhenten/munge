use MooseX::Declare;

class t::Munge::Config {
    use Munge::Config;
    use Data::Dumper;
    use Test::Sweet;

    test basic {
        my $config;

        lives_ok {
            $config = Munge::Config::config();
        }
        'We can call config';

        is( ref $config, 'HASH', 'its a hashref' );
    }

}
