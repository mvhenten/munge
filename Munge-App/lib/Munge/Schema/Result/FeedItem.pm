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
    "guid",
    { data_type => "varchar", is_nullable => 1, size => 32 },
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

=head2 C<index_guid>

=over 4

=item * L</guid>

=back

=cut

__PACKAGE__->add_unique_constraint( "index_guid", ["guid"] );

=head1 RELATIONS

=head2 feed

Type: belongs_to

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
    "feed", "Munge::Schema::Result::Feed",
    { id            => "feed_id" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-09-19 00:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XeM2+Zrt4RnrVXmtQKKjDQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
