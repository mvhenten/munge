use MooseX::Declare;
use MooseX::StrictConstructor;

class Munge::Model::Google::ReaderAPI {
    use Data::Dumper;
    use JSON qw|decode_json|;
    use Munge::Env qw|GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET|;
    use LWP::UserAgent;
    use Munge::Model::AccountFeed;
    use URI;
    use Munge::Util qw|is_url|;

    sub URL_SUBSCRIPTIONS {
        return 'https://www.google.com/reader/api/0/subscription/list?output=json';
    }

    has oauth2_uri => (
        is => 'ro',
        isa => 'URI',
        default => sub {
            return URI->new('https://accounts.google.com/o/oauth2');
        },
    );

    has redirect_uri => (
        is => 'ro',
        isa => 'URI',
        required => 1,
    );

    with 'Munge::Role::Account';

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

            my $uri = is_url( $url );
            next if not $uri;

            my $subscription =
              Munge::Model::AccountFeed->subscribe( $self->account, $uri );

            push( @collect, $subscription );
        }

        return @collect;
    }

    method _get_subscriptions ( $authorization_code ) {
        my $access = $self->_get_access_token( $authorization_code );

        my $ua = LWP::UserAgent->new;
        $ua->default_header( Authorization => 'OAuth ' . $access );

        my $response = $ua->get(URL_SUBSCRIPTIONS());
        my $json     = decode_json( $response->content );

        return [] if not $json;

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
            client_id     => GOOGLE_CLIENT_ID(),
            client_secret => GOOGLE_CLIENT_SECRET(),
            redirect_uri  => $self->redirect_uri->as_string,
            scope         => 'https://www.google.com/reader/api/',
        );
    }


}

1;
