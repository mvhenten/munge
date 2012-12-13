package Munge::Types;

use strict;
use warnings;

#use Munge::Model::Feed;
#use Munge::Model::Feed::ParserItem;
#use Munge::Schema::Result::Feed;

use MooseX::Types::Moose qw/Int HashRef Str Any Object/;
use MooseX::Types -declare => [qw|Account Feed Uri UUID ParserItem|];

class_type 'Account' => { class => 'Munge::Schema::Result::Account' };

class_type 'Feed' => { class => 'Munge::Model::Feed' };

class_type 'Uri' => { class => 'URI' };

subtype ParserItem,
  as Object;    #=> { class => 'Munge::Model::Feed::ParserItem' };

subtype UUID, as Str,
  where { use bytes; bytes::length($_) == 16 },
  message { "UUID is 16 bytes" };

coerce UUID, from Str, via { uuid_from_string($_) };

use Data::UUID;

sub uuid_from_string {
    my ($str) = @_;

    my $ug = Data::UUID->new();

    return $ug->from_b64string($str) if length($str) == 24;
    return $ug->from_hexstring($str) if $str =~ /0x[[:alnum:]]{32}/x;
    return $ug->from_string($str)    if _is_rfc4122_string($str);

    return;
}

sub _is_rfc4122_string {
    my ($str) = @_;

    return 1
      if $str =~
      /[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}/;

    return 0;
}

1;
