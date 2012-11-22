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

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 feed_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 account_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

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
  is_nullable: 1

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 read

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 starred

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "feed_id",
    {
        data_type      => "integer",
        extra          => { unsigned => 1 },
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "account_id",
    {
        data_type      => "integer",
        extra          => { unsigned => 1 },
        is_foreign_key => 1,
        is_nullable    => 0,
    },
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
        is_nullable               => 1,
    },
    "modified",
    {
        data_type                 => "datetime",
        datetime_undef_if_invalid => 1,
        is_nullable               => 1,
    },
    "read",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "starred",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "created",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        default_value             => \"current_timestamp",
        is_nullable               => 0,
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<account_feed_uuid>

=over 4

=item * L</uuid>

=item * L</account_id>

=back

=cut

__PACKAGE__->add_unique_constraint( "account_feed_uuid",
    [ "uuid", "account_id" ] );

=head1 RELATIONS

=head2 account

Type: belongs_to

Related object: L<Munge::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
    "account",
    "Munge::Schema::Result::Account",
    { id            => "account_id" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 feed

Type: belongs_to

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
    "feed", "Munge::Schema::Result::Feed",
    { id            => "feed_id" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-22 09:57:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jNcV+Lg458edm5S6iGf/AQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
