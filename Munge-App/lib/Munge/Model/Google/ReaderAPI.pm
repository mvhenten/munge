use MooseX::Declare;
use MooseX::StrictConstructor;

class Munge::Model::Google::ReaderAPI {
    use Data::Dumper;
    use JSON qw|decode_json|;
    use LWP::UserAgent;
    use Munge::Model::AccountFeed;
    use URI;

    sub URL_SUBSCRIPTIONS {
        return 'https://www.google.com/reader/api/0/subscription/list?output=json';
    }

    has base_uri => (
        is => 'ro',
        isa => 'URI',
        required => 1,
    );

    has oauth2_uri => (
        is => 'ro',
        isa => 'URI',
        default => sub {
            return URI->new('https://accounts.google.com/o/oauth2');
        },
    );

    has _redirect_uri => (
        is => 'ro',
        isa => 'URI',
        lazy_build => 1,
    );

    with 'Munge::Role::Account';

    method _build__redirect_uri {
        my $uri = $self->base_uri->clone;
        $uri->path( 'manage/reader/token' );

        return $uri;
    }

    method get_auth_code_uri {
        my $uri        = $self->_get_oauth2_uri('auth');
        my %query_form = $self->_get_config();

        delete( $query_form{client_secret} );

        $uri->query_form(
            %query_form,
            access_type     => 'offline',
            approval_prompt => 'force',
            response_type   => 'code',
        );

        return $uri;
    }

    method import_feeds( Str $authorization_code ) {
        my $subscriptions = $self->_get_subscriptions( $authorization_code );

        my @collect;

        foreach my $subscription ( @{ $subscriptions } ) {
            my ( $url ) =  $subscription->{id} =~ /feed\/(.+)/m;

            my $feed =
              Munge::Model::AccountFeed->subscribe( $self->account, URI->new($url), $subscription->{title} );

            push( @collect, $feed );
        }

        return @collect;
    }

    method _get_subscriptions ( $authorization_code ) {
        my $access = $self->_get_access_token( $authorization_code );

        my $ua = LWP::UserAgent->new;
        $ua->default_header( Authorization => 'OAuth ' . $access );

        my $response = $ua->get(URL_SUBSCRIPTIONS());
        my $json     = decode_json( $response->content );

        return $json->{subscriptions};
    }

    method _get_access_token( $authorization_code ) {
        my $uri = $self->_get_oauth2_uri('token');

        my $ua       = LWP::UserAgent->new;
        my $response = $ua->post( $uri, {
            $self->_get_config(),
            code       => $authorization_code,
            grant_type => 'authorization_code',
        });

        my $json     = decode_json( $response->content );

        return $json->{access_token};
    }

    method _get_oauth2_uri ( $path ){
        my $uri = $self->oauth2_uri->clone;
        $uri->path_segments( $uri->path_segments, $path );

        return $uri;
    }

    method _get_config {
        # todo inject these, make attributes
        return (
            client_id     => $ENV{google_api_client_id},
            client_secret => $ENV{google_api_client_secret},
            redirect_uri  => $self->_redirect_uri->as_string,
            scope         => 'https://www.google.com/reader/api/',
        );
    }


}

1;
