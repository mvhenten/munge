use MooseX::Declare;

=head1 NAME

Munge::Model::Feed::Parser

=head1 DESCRIPTION

Wrapper around XML::Feed

=head1 SYNOPSIS

    my $parsed_feed = Munge::Model::Feed::Parser->new(
        content => $response->content,
    );

    my @items = $parsed_feed->item_list;

=cut

class Munge::Model::Feed::Parser {
    use XML::Feed;
    use Try::Tiny;
    use Munge::Model::Feed::ParserItem;
    use Munge::Util qw|strip_html_comments|;

    has content => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has items => (

        #        traits     => ['Array'],
        is         => 'ro',
        isa        => 'ArrayRef[Munge::Model::Feed::ParserItem]',
        auto_deref => 1,
        lazy_build => 1,
    );

    has xml_feed => (
        is         => 'ro',
        isa        => 'Maybe[XML::Feed]',
        lazy_build => 1,
        handles    => [
            qw|
              title
              link
              tagline
              description
              author
              language
              copyright
              modified
              generator|
        ],
    );

    method _build_items {
        return [] if not $self->xml_feed;

        my @items =
          map { Munge::Model::Feed::ParserItem->new( entry => $_ ) }
          $self->xml_feed->entries;

        return \@items;
    }

    method _build_xml_feed {
        my $feed;

        my $content = strip_html_comments( $self->content );
#        $content =~ s/[[:cntrl:]]+//g;

        try {
            $feed = XML::Feed->parse( \$content );
        }
        catch {
            warn "Unable to parse feed: $_";
        };

        return $feed;
    }
}
