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

    test parser_item_uuid {
        my $feed = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;

        my $item = Munge::Model::Feed::ParserItem->new( entry => $entry );

        is(
            $item->uuid,
            '82E912E1-ECD6-3263-B4EC-677489F59D4E',
            qq|UUID is created correctly|
        );
    }

    test parser_item_uuid_bin {
        my $feed    = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;
        my $item    = Munge::Model::Feed::ParserItem->new( entry => $entry );
        my $ug      = Data::UUID->new;
        my $bin     = $ug->from_string('82E912E1-ECD6-3263-B4EC-677489F59D4E');

        is( $ug->compare( $bin, $item->uuid_bin ), 0, q|Bin UUID as expected| );
    }

    test parser_item_uuid_compare {
        my $feed    = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;
        my $item    = Munge::Model::Feed::ParserItem->new( entry => $entry );

        my $ug = Data::UUID->new;

        is( $ug->from_string( $item->uuid ),
            $item->uuid_bin, 'string computes to binary' );
        is( $ug->to_string( $item->uuid_bin ),
            $item->uuid, 'binary computes to string' );
    }

    test parser_item_values {
        my %expected = (
            title   => 'Atom-Powered Robots Run Amok',
            link    => 'http://example.org/2003/12/13/atom03',
            content => 'Some text.',
        );

        my $feed    = XML::Feed->parse( \$self->atom_data );
        my ($entry) = $feed->entries;
        my $item    = Munge::Model::Feed::ParserItem->new( entry => $entry );

        my %values = map { $_ => $item->$_ } keys %expected;

        is_deeply( \%values, \%expected, 'got expected values' );
    }

}
