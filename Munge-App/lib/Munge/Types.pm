package Munge::Types;

use MooseX::Types::Moose qw/Int HashRef Str/;
use MooseX::Types -declare => [qw|Account Feed Uri UUID|];


class_type 'Account' => { class => 'Munge::Schema::Result::Account' };

class_type 'Feed' => { class => 'Munge::Schema::Result::Feed' };

class_type 'Uri' => { class => 'URI' };

subtype UUID,
      as Str,
      where { bytes::length($_) == 16 },
      message { "UUID is 16 bytes" };


coerce UUID,
    from Str,
        via { uuid_from_string($_) };


use Data::UUID;

sub uuid_from_string {
    my ( $str ) = @_;

    my $ug = Data::UUID->new();

    return $ug->from_string( $str );
}

1;
