package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer ':syntax';
use Data::Dumper;
use Munge::Email::Verification;
use Munge::Model::Account;

prefix '/account';

get '/create' => sub {
    return
      '<form action="/account/create" method="post"><input name="username" /><input type="password" name="password" /><input type="submit" /></form>';
};

post '/create' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account = Munge::Model::Account->new()->create( $username, $password );

    my $mail = Munge::Email::Verification->new( account => $account );
    $mail->submit();

    redirect 'account/login';
};

get '/login' => sub {
    return redirect '/' if session('authenticated');

    return template 'account/login',
      {
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
