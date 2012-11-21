use MooseX::Declare;

use strict;
use warnings;

class Munge::Model::Feed::ParserItem {
    use Data::UUID qw|NameSpace_URL|;
    use DateTime;

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

    has modified => (
        is         => 'ro',
        lazy_build => 1,
    );

    method _build_modified {
        return $self->entry->modified || DateTime->now();
    }

    method _build_content {
        my $content = $self->_content->body || $self->_summary->body || '';
        
        return $content;
    }

    method _build_uuid {
        my $uuid = Data::UUID->new();

        return $uuid->create_from_name_str( NameSpace_URL, $self->link );
    }

    method _build_uuid_bin {
        my $uuid = Data::UUID->new();

        return $uuid->from_string( $self->uuid );
    }

}
