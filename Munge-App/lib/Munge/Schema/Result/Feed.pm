use utf8;
package Munge::Schema::Result::Feed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Munge::Schema::Result::Feed

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components( "InflateColumn::DateTime", "TimeStamp" );

=head1 TABLE: C<feed>

=cut

__PACKAGE__->table("feed");

=head1 ACCESSORS

=head2 link

  data_type: 'varchar'
  is_nullable: 0
  size: 2048

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 512

=head2 description

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4096

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 uuid

  data_type: 'binary'
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
    "link",
    { data_type => "varchar", is_nullable => 0, size => 2048 },
    "title",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 512
    },
    "description",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 4096
    },
    "updated",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        default_value             => "0000-00-00 00:00:00",
        is_nullable               => 0,
    },
    "created",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        default_value             => "0000-00-00 00:00:00",
        is_nullable               => 0,
    },
    "uuid",
    { data_type => "binary", is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->set_primary_key("uuid");

=head1 RELATIONS

=head2 account_feed_items

Type: has_many

Related object: L<Munge::Schema::Result::AccountFeedItem>

=cut

__PACKAGE__->has_many(
    "account_feed_items",
    "Munge::Schema::Result::AccountFeedItem",
    { "foreign.feed_uuid" => "self.uuid" },
    { cascade_copy        => 0, cascade_delete => 0 },
);

=head2 account_feeds

Type: has_many

Related object: L<Munge::Schema::Result::AccountFeed>

=cut

__PACKAGE__->has_many(
    "account_feeds",
    "Munge::Schema::Result::AccountFeed",
    { "foreign.feed_uuid" => "self.uuid" },
    { cascade_copy        => 0, cascade_delete => 0 },
);

=head2 feed_items

Type: has_many

Related object: L<Munge::Schema::Result::FeedItem>

=cut

__PACKAGE__->has_many(
    "feed_items",
    "Munge::Schema::Result::FeedItem",
    { "foreign.feed_uuid" => "self.uuid" },
    { cascade_copy        => 0, cascade_delete => 0 },
);

=head2 accounts

Type: many_to_many

Composing rels: L</account_feeds> -> account

=cut

__PACKAGE__->many_to_many( "accounts", "account_feeds", "account" );

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-20 00:36:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YV+WvpoRNvGDQ6czPPrZkA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->has_many(
    "unread_items",
    "Munge::Schema::Result::FeedItem",
    sub {
        my ($args) = @_;

        my ( $foreign, $self ) = @{$args}{qw|foreign_alias self_alias|};

        return {
            "$foreign.feed_id" => { -ident => "$self.id" },
            "$foreign.read"    => 0,
        };
    }
);

1;
