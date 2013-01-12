package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer ':syntax';
use Munge::Model::Account;
use Data::Dumper;

prefix '/account';

get '/create' => sub {
    return
      '<form action="/account/create" method="post"><input name="username" /><input type="password" name="password" /><input type="submit" /></form>';
};

post '/create' => sub {
    my ( $username, $password ) = @{ params() }{qw|username password|};

    my $account = Munge::Model::Account->new()->create( $username, $password );

    redirect 'account/login';
};

get '/login' => sub {
    return redirect '/' if session('authenticated');

    return template 'account/login', {}, { layout => undef };
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

    redirect 'account/login?failed=1';

};

true;
