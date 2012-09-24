use MooseX::Declare;

class t::Munge::Model::Feed::ParserItem {

    use File::Slurp qw|read_file|;
    use Munge::Model::Feed::ParserItem;
    use XML::Feed;
    use Data::UUID;
    use Test::Sweet;

    has atom_data => (
        is      => 'ro',
        isa     => 'Str',
        default => sub {
            return read_file('./t/resource/atom.xml');
        },
    );

    test uuid {
        my $feed = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;

        my $item = Munge::Model::Feed::ParserItem->new( entry => $entry );

        is(
            $item->uuid,
            '82E912E1-ECD6-3263-B4EC-677489F59D4E',
            qq|UUID is created correctly|
        );
    }

    test uuid_bin {
        my $feed = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;

        my $item = Munge::Model::Feed::ParserItem->new( entry => $entry );
        my $ug   = Data::UUID->new;
        my $bin  = $ug->from_string('82E912E1-ECD6-3263-B4EC-677489F59D4E');

        is( $ug->compare( $bin, $item->uuid_bin ), 0, q|Bin UUID as expected| );
    }

    test handles {
        my %expected = (
            title   => '',
            link    => '',
            summary => '',
        );

        my $feed    = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;
        my $item    = Munge::Model::Feed::ParserItem->new( entry => $entry );

        foreach my $key ( keys %expected ) {
            $expected{$key} = '' . $item->$key;
        }

        use Data::Dumper;
        warn Dumper( \%expected );
        fail('fixme');
    }

}
