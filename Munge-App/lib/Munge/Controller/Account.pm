package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer ':syntax';
use Munge::Model::Account;

prefix '/account';

get '/create' => sub {
    return
      '<form method="post"><input name="username" /><input type="password" name="password" /><input type="submit" /></form>';
};

post '/create' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account = Munge::Model::Account->new()->create( $username, $password );

    redirect 'account/login';
};

get '/login' => sub {
    return
      '<form method="post"><input name="username" /><input type="password" name="password" /><input type="submit" /></form>';
};

post '/login' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account    = Munge::Model::Account->new();
    my $account_rs = $account->load($username);

    if ( $account && $account->validate( $account_rs, $password ) ) {
        session( account => $account_rs, authenticated => true );
        redirect '/';
        return;
    }

    if ( not $account_rs ) {
        debug "Cannot load $username";
    }
    else {
        debug "Validation failed for $username, $password";
    }

    redirect 'account/login?failed=1';

};

get '/logout' => sub {

};

true;
