package Munge::Controller::Feed;

use Dancer ':syntax';

prefix '/feed';

get '/list' => sub {

    return 'list feed';
};

get '/create' => sub {

    return
      '<form method="post"><input name="url" /><input type="submit" /></form>';
};

post '/create' => sub {
    return 1;
};

true;
