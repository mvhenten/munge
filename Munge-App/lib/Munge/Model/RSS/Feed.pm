use MooseX::Declare;

class Munge::Model::RSS::Feed {
    use XML::Feed;
    use Munge::Model::RSS::Feed::Item;

    has content => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has items => (
        is         => 'ro',
        isa        => 'ArrayRef[Munge::Model::RSS::Feed::Item]',
        auto_deref => 1,
        lazy_build => 1,
    );

    has _xml_feed => (
        is         => 'ro',
        isa        => 'XML::Feed',
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
        my @items =
          map { Munge::Model::RSS::Feed::Item->new( entry => $_ ) }
          $self->_xml_feed->entries;

        return \@items;
    }

    method _build__xml_feed {
        return XML::Feed->parse( \$self->content );
    }
}
