use MooseX::Declare;

class Munge::Model::Feed::Client {
    use HTTP::Status qw|:constants|;
    use DateTime::Format::HTTP;
    use LWP::UserAgent;

    has feed_uri => (
        is       => 'ro',
        isa      => 'URI',
        required => 1,
    );

    has last_modified_since => (
        is       => 'ro',
        isa      => 'Maybe[DateTime]',
        required => 1,
    );

    has updated => (
        is         => 'ro',
        isa        => 'Bool',
        lazy_build => 1,
    );

    has content => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has _response => (
        is         => 'ro',
        isa        => 'HTTP::Response',
        lazy_build => 1,
        handles    => {
            response_code => 'code',
            status_line   => 'status_line',
            success       => 'is_success',
        }
    );

    method _build_updated {
        return $self->_response->code != HTTP_NOT_MODIFIED;
    }

    method _build__response {

        my $ua = LWP::UserAgent->new;

        if ( $self->last_modified_since ) {
            $ua->default_header(
                'If-Modified-Since' => DateTime::Format::HTTP->format_datetime(
                    $self->last_modified_since
                )
            );
        }

        return $ua->get( $self->feed_uri );
    }

    method _build_content {
        return '' if not $self->_response->is_success;
        return $self->_response->decoded_content;
    }
}
