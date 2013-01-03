use MooseX::Declare;

use strict;
use warnings;

class t::Munge::Util {
    use Munge::Util qw|strip_html human_date_string|;
    use DateTime;
    use Test::Sweet;

    test human_date_string {
        my @cases = (
            {
                label    => '1 year ago',
                expected => '1 year',
                dt       => DateTime->now->subtract( years => 1, days => 1 ),
            },
            {
                label    => '1 month ago',
                expected => '1 month',
                dt       => DateTime->now->subtract( months => 1, days => 1 ),
            },
            {
                label    => '2 months ago',
                expected => '2 months',
                dt       => DateTime->now->subtract( months => 2, days => 1 ),
            },
            {
                label    => '3 weeks ago',
                expected => '3 weeks',
                dt       => DateTime->now->subtract( weeks => 3, days => 1 ),
            },
            {
                label    => '1 week ago',
                expected => '1 week',
                dt       => DateTime->now->subtract( weeks => 1, days => 1 ),
            },
            {
                label    => '6 days ago',
                expected => '6 days',
                dt       => DateTime->now->subtract( days => 6 ),
            },
            {
                label    => '11 hours ago',
                expected => '11 hours',
                dt       => DateTime->now->subtract( hours => 11 ),
            },
            {
                label    => '10 minutes ago',
                expected => '10 minutes',
                dt       => DateTime->now->subtract( minutes => 10 ),
            },
        );

        foreach my $case (@cases) {
            my ( $expected, $label, $dt ) = @{$case}{qw|expected label dt|};

            my $actual = human_date_string($dt);

            is( $actual, $expected, $label );

        }
    }

    test test_strip_html {
        my @cases = (
            {
                label    => 'Allow attributes',
                input    => [ '<a alt="test" href="test">a</a>', qw|a| ],
                expected => '<a alt="test" href="test">a</a>',
            },
            {
                label => 'Allow some tags, some not',
                input =>
                  [ '<div><p><b>test<em>me</em></b></p></div>', qw|p b em| ],
                expected => '<p><b>test<em>me</em></b></p>',
            },
            {
                label    => 'Allow self-closing stuff',
                input    => [ '<p>hello world<br /></p>', qw|br| ],
                expected => 'hello world<br />',
            },
            {
                label    => 'Stern defaults strip everything',
                input    => ['<p><em>hello</em> <b>world</b><br/></p>'],
                expected => 'hello world',
            }
        );

        foreach my $case (@cases) {
            my ( $html, @tags ) = @{ $case->{input} };

            my $actual = strip_html( $html, @tags );

            is( $actual, $case->{expected}, $case->{label} );

        }
        #
        #my $html = '<script>strip me</script><b>allow b</b><p>allow <em>p</em></p><div>me too</div>';
        #my $expected = 'strip me<b>allow b</b><p>allow <em>p</em></p>me too';
        #my $actual = strip_html( $html, qw|b p em| );
        #
        #is( $actual, $expected, 'got expected stripped html');
    }

}
