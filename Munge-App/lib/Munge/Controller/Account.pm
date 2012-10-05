package Munge::Controller::Account;

use Crypt::SaltedHash;
use Dancer::Plugin::DBIC 'schema';
use Dancer ':syntax';

prefix '/account';

get '/create' => sub {
    return
      '<form method="post"><input name="username" /><input type="password" name="password" /><input type="submit" /></form>';
};

post '/create' => sub {
    my $csh = Crypt::SaltedHash->new( algorithm => 'SHA-1' );

    $csh->add('secret');
    my $salted = $csh->generate;
    my $valid = Crypt::SaltedHash->validate( $salted, 'secret' );

    return 'list feed';
};

get '/login' => sub {

};

post '/login' => sub {

};

get '/logout' => sub {

};

true;
