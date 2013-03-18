package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer ':syntax';
use Data::Dumper;
use Munge::Email::Verification;
use Munge::Model::Account;
use Data::Validate::Email qw|is_email|;

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

    return template 'account/login',
      {
        verifcation_sent  => param('signup'),
        need_verification => param('need_verification'),
        login_failed      => param('failed'),
      },
      { layout => undef };
};

get '/logout' => sub {

    session->destroy;

    redirect 'account/login';
};

post '/login' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load($username);

    if ( $account_rs && $account->validate( $account_rs, $password ) ) {
        session authenticated => true;
        session account       => { $account_rs->get_inflated_columns() };
        redirect '/';
        return;
    }

    if ( not $account_rs ) {
        debug "Cannot load $username";
    }
    else {
        debug "Validation failed for $username";
    }

    if ( not $account_rs->verified ) {
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

        session authenticated => true;
        session account       => { $account_rs->get_inflated_columns() };
        redirect '/';
        return;
    }
    else {
        debug "Cannot verificate $username with token $token";
    }

    redirect 'account/verify?failed=1';
};

true;
