use MooseX::Declare;

use strict;
use warnings;

class Munge::Model::Feed::ParserItem {
    use Encode qw|encode_utf8|;
    use Data::UUID qw|NameSpace_URL|;
    use Munge::Util qw|strip_html string_ellipsize sanitize_html|;
    use DateTime;

    has entry => (
        is       => 'ro',
        isa      => 'Any',
        required => 1,
        handles  => {
            title      => 'title',
            link       => 'link',
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

    has summary => (
        is         => 'ro',
        lazy_build => 1,
    );

    has modified => (
        is         => 'ro',
        lazy_build => 1,
    );

    has issued => (
        is         => 'ro',
        lazy_build => 1,
    );

    has tags => (
        is         => 'ro',
        lazy_build => 1,
    );

    has author => (
        is         => 'ro',
        lazy_build => 1,
    );

    method _build_modified {
        return
             $self->entry->modified
          || $self->entry->issued
          || DateTime->now();
    }

    method _build_issued {
        return
             $self->entry->issued
          || $self->entry->modified
          || DateTime->now();
    }

    method _build_content {
        my $content = $self->_content->body || $self->_summary->body || '';

        return sanitize_html($content);
    }

    method _build_summary {
        return string_ellipsize(
            strip_html( $self->_summary->body || $self->content ) || '' );
    }

    method _build_tags {
        my @tags = $self->entry->tags;

        return join( q|,|, @tags );
    }

    method _build_author {
        my $author = $self->entry->author;

        if ( ref $author eq 'ARRAY' ) {
            $author = join( ', ', @$author );
        }

        return $author;
    }

    method _build_uuid {
        my $uuid = Data::UUID->new();

        return $uuid->create_from_name_str( NameSpace_URL,
            encode_utf8( $self->link ) );
    }

    method _build_uuid_bin {
        my $uuid = Data::UUID->new();

        return $uuid->from_string( $self->uuid );
    }

}
