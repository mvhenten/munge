use MooseX::Declare;

use strict;
use warnings;

class t::Munge::Util {
    use Munge::Util qw|strip_html|;
    
    use Test::Sweet;
    
    test test_strip_html {
        my @cases = (
            {
                label    => 'Allow attributes',
                input    => ['<a alt="test" href="test">a</a>', qw|a|],
                expected => '<a alt="test" href="test">a</a>',
            },
            {
                label    => 'Allow some tags, some not',
                input    => ['<div><p><b>test<em>me</em></b></p></div>', qw|p b em|],
                expected => '<p><b>test<em>me</em></b></p>',
            },
            {
                label    => 'Allow self-closing stuff',
                input    => ['<p>hello world<br /></p>', qw|br|],
                expected => 'hello world<br />',
            },
            {
                label    => 'Stern defaults strip everything',
                input    => ['<p><em>hello</em> <b>world</b><br/></p>'],
                expected => 'hello world',
            }
        );

        foreach my $case ( @cases ) {
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