package Munge::Controller::Feed;

use Dancer ':syntax';

prefix undef;


get '/' => sub {
    # Munge::Model::Account->new( schema => $self->schema )->find
    
    
    template 'feed/index';
    
};


true;
