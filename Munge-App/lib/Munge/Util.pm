package Munge::Util;

=NAME Munge::Util;

=DESCRIPTION

    Every project needs an util library right?

=cut 

use strict;
use warnings;

use HTML::Restrict;
use Exporter::Lite;

our @EXPORT_OK = qw|strip_html sanitize_html restrict_html|;

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
