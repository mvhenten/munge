use MooseX::Declare;

class Munge::Model::Feed::ParserItem {
    use Data::UUID qw|NameSpace_URL|;
    use HTML::Tidy;

    has entry => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
        handles  => {
            'title'    => 'title',
            'link'     => 'link',
            '_summary' => 'summary',
            '_content' => 'content',
        },
    );

    has uuid => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has uuid_bin => (
        is         => 'ro',
        isa        => 'Value',
        lazy_build => 1,
    );

    has content => (
        is         => 'ro',
        lazy_build => 1,
    );

    method _build_content {
        my $tidy = HTML::Tidy->new();

        $tidy->ignore( type => TIDY_INFO );
        $tidy->ignore( type => TIDY_WARNING );
        $tidy->ignore( type => TIDY_ERROR );

        my $content = $self->_content->body || $self->_summary->body || '';

        return $tidy->clean($content);
    }

    method _build_uuid {
        my $uuid = new Data::UUID;
        return $uuid->create_from_name_str( NameSpace_URL, $self->link );
    }

    method _build_uuid_bin {
        my $uuid = new Data::UUID;

        return $uuid->from_string( $self->uuid );
    }

}
