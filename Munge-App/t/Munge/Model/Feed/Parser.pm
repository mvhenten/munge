use MooseX::Declare;

class t::Munge::Model::Feed::Parser {

    use Cwd qw|abs_path cwd|;
    use File::Slurp qw|read_file|;
    use Munge::Model::Feed::Parser;
    use Test::Sweet;

    has atom_data => (
        is      => 'ro',
        isa     => 'Str',
        default => sub {
            return read_file('./t/resource/atom.xml');
        },
    );

    test items {
        my $feed =
          Munge::Model::Feed::Parser->new( content => $self->atom_data );
        my @items = $feed->items;

        is( scalar @items, 1, 'One item in sample feed' );
        isa_ok(
            $items[0],
            'Munge::Model::Feed::ParserItem',
            qq|Got correct type|
        );
    }

    test handle_basics {
        my $feed =
          Munge::Model::Feed::Parser->new( content => $self->atom_data );

        is( $feed->content, $self->atom_data, 'Content passed correctly' );

        my %expected = (
            'link'        => 'http://example.org/',
            'language'    => undef,
            'copyright'   => undef,
            'author'      => 'John Doe',
            'description' => undef,
            'generator'   => undef,
            'modified'    => '2003-12-13T18:30:02',
            'tagline'     => undef,
            'title'       => 'Example Feed'
        );

        for my $key ( keys %expected ) {
            is( $feed->$key, $expected{$key},
                qq|Handled method $key returns expected value| );
        }

    }

}
