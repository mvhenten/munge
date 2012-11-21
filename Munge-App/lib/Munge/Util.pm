package Munge::Util;

=NAME Munge::Util;

=DESCRIPTION

    Every project needs an util library right?

=cut

use strict;
use warnings;

use Data::UUID;
use Carp::Assert;
use HTML::Restrict;
use Exporter::Lite;
use Munge::Types qw|UUID|;
use Method::Signatures;

our @EXPORT_OK = qw|
    strip_html_comments
    uuid_string
    strip_html
    sanitize_html
    restrict_html
    string_ellipsize
|;

sub HTML5_TAGS {
    return qw|
      article aside bdi command details summary figure figcaption footer header
      hgroup mark meter section time wbr audio video source embed track canvas
      |;
}

sub HTML4_TAGS {
    return qw|
      a abbr b blockquote br caption cite code dd dl dt em
      h2 h3 h4 hr i img li ol p pre q s small span strike strong
      sub sup table td tfoot th thead tr tt u ul
      |;
}

=item uuid_string ( $binary_uuid )

Saves one line of code and maybe a use statement. possibly some cognitive load

=cut

func uuid_string ( $uuid ) {
    assert( is_UUID( $uuid ) );

    my $ug = Data::UUID->new();

    return $ug->to_string( $uuid );
}

=item string_ellipsize ( $str, $max_length, $ellipse )

Generate a teaser from $string

=cut

func string_ellipsize ( Str $string, Int $max_length = 240, Str $ellipse = '...' ){
    my $chop = substr( $string, 0, $max_length );

    my $after_chop = substr( $string, 0, $max_length + 1 );

    if( not $after_chop || $after_chop =~ /\s/ ){
        # character after chop was a whitespace char
        return $chop . $ellipse;
    }

    #find last word boundary
    my $last_space = index( reverse( $chop ), ' ' );


    return substr( $chop, 0, $max_length - ( 1 + $last_space ) ) . $ellipse;
}

=item uuid_string ( $binary_uuid )

Strip every html comment

=cut

sub strip_html_comments {
   my ( $html ) = @_;

    $html =~ s/<!--(.+?)-->//gsm;

    return $html;
}


=item sanitize_html ( $html )

Strip unwanted tags, most notably iframe, script, div, style, and h1.
Also, forms are not allowed.

When displaying foreing html, these are propably the most obvious to go first.
N.B. That does not mean the HTML is considered "safe". but may be "safe enough"

=cut

sub sanitize_html {
    my ($html) = @_;

    my @allowed_tags = ( HTML4_TAGS, HTML5_TAGS );
    return strip_html( $html, @allowed_tags );
}

=item sanitize_html ( $html, @allowed_tags )

Strip tags except for the @allowed_tags. notably, the attributes
"src", "alt" and "href" are kept, all others are stripped.

=cut

sub strip_html {
    my ( $html, @allowed_tags ) = @_;

    my @allowed_attributes = qw|/ src alt href|;
    my %rules = map { $_ => \@allowed_attributes } @allowed_tags;

    return restrict_html( $html, %rules );
}

=item restrict_html ( $html, %allowed_tags )

Wrapper around HTML::Restrict. %allowed_tags is passed in as the "rules" hashref.

=cut

sub restrict_html {
    my ( $html, %allowed_tags ) = @_;

    my $hr = HTML::Restrict->new();
    $hr->set_rules( \%allowed_tags );
    return $hr->process($html);
}

1;
