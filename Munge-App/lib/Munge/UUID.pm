use MooseX::Declare;

=head1 NAME

Munge::UUID

=head1 DESCRIPTION

Build uuids from links.

=head1 SYNOPSIS

    my $link = URI->new( $url );
    my $uuid = Munge::UUID->new( uri => $link );

    my $hex_uuid = $uuid->uuid;
    my $bin_uuid = $uuid->uuid_bin;

=cut

class Munge::UUID {

    use Data::UUID qw|NameSpace_URL|;
    use URI;

    has uri => (
        is  => 'ro',
        isa => 'URI',
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

    method _build_uuid {
        my $uuid = new Data::UUID;
        return $uuid->create_from_name_str( NameSpace_URL,
            $self->uri->as_string );
    }

    method _build_uuid_bin {
        my $uuid = new Data::UUID;
        return $uuid->from_string( $self->uuid );
    }
}
