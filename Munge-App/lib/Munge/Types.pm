package Munge::Types;

use MooseX::Types::Moose qw/Int HashRef/;
use MooseX::Types -declare => [qw|Account Feed Uri|];

class_type 'Account' => { class => 'Munge::Schema::Result::Account' };

class_type 'Feed' => { class => 'Munge::Schema::Result::Feed' };

class_type 'Uri' => { class => 'URI' };

1;
