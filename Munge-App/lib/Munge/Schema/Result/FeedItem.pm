use utf8;
package Munge::Schema::Result::FeedItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Munge::Schema::Result::FeedItem

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

=head1 TABLE: C<feed_item>

=cut

__PACKAGE__->table("feed_item");

=head1 ACCESSORS

=head2 uuid

  data_type: 'binary'
  is_nullable: 0
  size: 16

=head2 link

  data_type: 'varchar'
  is_nullable: 0
  size: 2048

=head2 author

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 2048

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 512

=head2 tags

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1024

=head2 summary

  data_type: 'text'
  is_nullable: 1

=head2 content

  data_type: 'mediumtext'
  is_nullable: 1

=head2 issued

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 1

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 1

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 feed_uuid

  data_type: 'binary'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 poster_image

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 2048

=cut

__PACKAGE__->add_columns(
    "uuid",
    { data_type => "binary", is_nullable => 0, size => 16 },
    "link",
    { data_type => "varchar", is_nullable => 0, size => 2048 },
    "author",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 2048
    },
    "title",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 512
    },
    "tags",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 1024
    },
    "summary",
    { data_type => "text", is_nullable => 1 },
    "content",
    { data_type => "mediumtext", is_nullable => 1 },
    "issued",
    {
        data_type                 => "datetime",
        datetime_undef_if_invalid => 1,
        default_value             => "0000-00-00 00:00:00",
        is_nullable               => 1,
    },
    "modified",
    {
        data_type                 => "datetime",
        datetime_undef_if_invalid => 1,
        default_value             => "0000-00-00 00:00:00",
        is_nullable               => 1,
    },
    "created",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        default_value             => \"current_timestamp",
        is_nullable               => 0,
    },
    "feed_uuid",
    {
        data_type      => "binary",
        is_foreign_key => 1,
        is_nullable    => 1,
        size           => 16
    },
    "poster_image",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 2048
    },
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
    { "foreign.feed_item_uuid" => "self.uuid" },
    { cascade_copy             => 0, cascade_delete => 0 },
);

#=head2 feed_uuid
#
#Type: belongs_to
#
#Related object: L<Munge::Schema::Result::Feed>
#
#=cut
#
#__PACKAGE__->belongs_to(
#    "feed_uuid",
#    "Munge::Schema::Result::Feed",
#    { uuid => "feed_uuid" },
#    {
#        is_deferrable => 1,
#        join_type     => "LEFT",
#        on_delete     => "RESTRICT",
#        on_update     => "RESTRICT",
#    },
#);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-20 00:51:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z+S5O0svpsK6UU4tOySRxw

# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 feed

Type: belongs_to

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
    "feed",
    "Munge::Schema::Result::Feed",
    { uuid => "feed_uuid" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "RESTRICT",
        on_update     => "RESTRICT",
    },
);

1;
