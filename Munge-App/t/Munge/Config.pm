use MooseX::Declare;

class t::Munge::Config {
    use Munge::Config;
    use Data::Dumper;
    use Test::Sweet;

    test basic {
        warn Dumper( Munge::Config::config() );
    }

}
