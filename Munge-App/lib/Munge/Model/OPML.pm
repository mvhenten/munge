use MooseX::Declare;

class Munge::Model::OPML {
    use Munge::Model::AccountFeed;
    use Munge::Model::Feed;
    use XML::XPath;
    use URI;

    with 'Munge::Role::Account';

    method import_feeds( Str $filename ) {
        my $xp = XML::XPath->new( filename => $filename );
        my $nodeset = $xp->find('//outline');

        my @collect;

        foreach my $node ( $nodeset->get_nodelist ) {
            my $link = URI->new( $node->getAttribute('xmlUrl') );

            my $subscription =
              Munge::Model::AccountFeed->subscribe( $self->account, $link );

            push( @collect, $subscription );
        }

        return \@collect;
    }
}

1;
