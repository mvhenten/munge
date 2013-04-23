package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer ':syntax';
use Data::Dumper;
use Data::Validate::Email qw|is_email|;
use Munge::Util qw|random_string|;
use Munge::Email::Verification;
use Munge::Model::Account;
use OAuth2::Google::Plus;
use OAuth2::Google::Plus::UserInfo;

prefix '/account';

get '/create' => sub {

    return template 'account/create',
      { error  => param('error'), },
      { layout => undef };
};

post '/create' => sub {
    my ( $username, $password, $confirm ) =
      @{ params() }{qw|username password password-confirm|};

    if ( not length($password) or ( $confirm ne $password ) ) {
        redirect 'account/create?error=password';
        return;
    }

    if ( not length($username) or ( not is_email($username) ) ) {
        redirect 'account/create?error=email';
        return;
    }

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load($username);

    if ($account_rs) {
        redirect 'account/create?error=email';
        return;
    }

    my $created_user =
      Munge::Model::Account->new()->create( $username, $password );
    my $mail = Munge::Email::Verification->new( account => $created_user );
    $mail->submit();

    redirect 'account/login?signup=1';
};

get '/login' => sub {
    return redirect '/' if session('authenticated');

    my $uri = URI->new( request()->uri_base );
    $uri->path('account/authorize/google/plus');

    my $plus = OAuth2::Google::Plus->new(
        client_id     => $ENV{google_api_client_id},
        client_secret => $ENV{google_api_client_secret},
        redirect_uri  => $uri->as_string,
    );

    return template 'account/login',
      {
        verifcation_sent  => param('signup'),
        need_verification => param('need_verification'),
        login_failed      => param('failed'),
        google_plus_buton => $plus->authorization_uri(),
      },
      { layout => undef };
};

get '/logout' => sub {

    session->destroy;

    redirect 'account/login';
};

get '/account/authorize/google/plus' => sub {
    return redirect '/' if not param('code');

    my $uri = URI->new( request()->uri_base );
    $uri->path('account/authorize/google/plus');

    my $plus = OAuth2::Google::Plus->new(
        client_id     => $ENV{google_api_client_id},
        client_secret => $ENV{google_api_client_secret},
        redirect_uri  => $uri->as_string,
    );

    # callback returns with a code in url
    my $access_token = $plus->authorize( param('code') );
    return redirect 'account/login?google_auth_error=1' if not $access_token;

    my $info =
      OAuth2::Google::Plus::UserInfo->new( access_token => $access_token );

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load( $info->email );

    if ($account_rs) {
        redirect_user_logged_in($account_rs);
        return;
    }

    my $created_user =
      Munge::Model::Account->new()->create( $info->email, random_string() );

    if ( $info->verified_email eq 'True' ) {
        $account->update( { verification => '' } );
    }
    else {
        my $mail = Munge::Email::Verification->new( account => $created_user );
        $mail->submit();
    }

    redirect_user_logged_in($created_user);
    return;
};

post '/login' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load($username);

    if ( $account_rs && $account->validate( $account_rs, $password ) ) {
        redirect_user_logged_in($account_rs);
        return;
    }

    if ( not $account_rs ) {
        debug "Cannot load $username";
    }
    else {
        debug "Validation failed for $username";
    }

    if ( $account_rs and not $account_rs->verified ) {
        my $mail = Munge::Email::Verification->new( account => $account_rs );
        $mail->submit();

        redirect 'account/login?need_verification=1';
    }

    redirect 'account/login?failed=1';

};

get '/verify/:token' => sub {
    return redirect '/' if session('authenticated');

    my $token = param('token');

    return template 'account/verify', { token => $token, }, { layout => undef };
};

post '/verify/:token' => sub {
    my ( $username, $password, $token ) =
      @{ params() }{qw|username password verification|};

    my $account = Munge::Model::Account->new();

    if ( $account->verificate( $username, $password, $token ) ) {
        my $account_rs = $account->load($username);
        redirect_user_logged_in($account_rs);
    }
    else {
        debug "Cannot verificate $username with token $token";
    }

    redirect 'account/verify?failed=1';
};

sub redirect_user_logged_in {
    my ($account_rs) = @_;

    session authenticated => true;
    session account       => { $account_rs->get_inflated_columns() };
    redirect '/';
    return;
}

true;
