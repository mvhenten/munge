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

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<feed>

=cut

__PACKAGE__->table("feed");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 guid

  data_type: 'varchar'
  is_nullable: 1
  size: 32

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

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "guid",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "link",
  { data_type => "varchar", is_nullable => 0, size => 2048 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 512 },
  "description",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4096 },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<index_guid>

=over 4

=item * L</guid>

=back

=cut

__PACKAGE__->add_unique_constraint("index_guid", ["guid"]);

=head1 RELATIONS

=head2 feed_items

Type: has_many

Related object: L<Munge::Schema::Result::FeedItem>

=cut

__PACKAGE__->has_many(
  "feed_items",
  "Munge::Schema::Result::FeedItem",
  { "foreign.feed_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-09-19 00:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Lgpu35oMtube2vNHo/p84A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
