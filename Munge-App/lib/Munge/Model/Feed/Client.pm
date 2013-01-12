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

    sub CLIENT_TIMEOUT {
        # Slow timeout, this value is still experimental. just dont want to
        # wait for slow hosts.
        return 2; 
    }
    
    sub USER_AGENT_STRING {

        # pretend we're google, prevents us being labelled as spammer by
        # stupid spamfilters that believe this. yeah.
        return 'FeedFetcher-Google; (+http://www.google.com/feedfetcher.html)';
    }

    method _build_updated {
        return $self->_response->code != HTTP_NOT_MODIFIED;
    }

    method _build__response {
        my $ua = LWP::UserAgent->new;

        $ua->agent( USER_AGENT_STRING() );
        $ua->timeout( CLIENT_TIMEOUT() );

        if ( $self->last_modified_since ) {
            $ua->default_header(
                'If-Modified-Since' => DateTime::Format::HTTP->format_datetime(
                    $self->last_modified_since
                )
            );
        }

        my $response = $ua->get( $self->feed_uri );
        return $response;
    }

    method _build_content {
        return '' if not $self->_response->is_success;
        return $self->_response->decoded_content;
    }
}
