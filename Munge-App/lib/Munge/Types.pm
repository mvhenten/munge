package Munge::Types;

use MooseX::Types::Moose qw/Int HashRef/;
use MooseX::Types -declare => [qw|Account Uri|];

class_type 'Account' => { class => 'Munge::Schema::Result::Account' };

class_type 'Uri' => { class => 'URI' };

1;
