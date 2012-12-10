use MooseX::Declare;

class Munge::Model::OPML {
    use Munge::Model::Feed;
    use XML::XPath;
    use URI;

    with 'Munge::Role::Account';

    has filename => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has feeds => (
        traits     => ['Array'],
        is         => 'ro',
        isa        => 'ArrayRef[Maybe[Munge::Model::Feed]]',
        lazy_build => 1,
        handles    => {
            count_feeds => 'count',
            get_feeds   => 'elements',
        }
    );

    method _build_feeds {
        my $xp = XML::XPath->new( filename => $self->filename );
        my $nodeset = $xp->find('//outline');

        my @collect;

        foreach my $node ( $nodeset->get_nodelist ) {
            my $link = URI->new( $node->getAttribute('xmlUrl') );
            my $uuid = Munge::UUID->new( uri => $link )->uuid_bin;

            my $feed = Munge::Model::Feed->new(
                link    => $link->as_string,
                uuid    => $uuid,
                account => $self->account,
            );

            $feed->store();
            push( @collect, $feed );
        }

        return \@collect;
    };
}

1;
