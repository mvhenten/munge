use utf8;
package Munge::Schema::Result::AccountFeedItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Munge::Schema::Result::AccountFeedItem

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

=head1 TABLE: C<account_feed_item>

=cut

__PACKAGE__->table("account_feed_item");

=head1 ACCESSORS

=head2 account_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 feed_item_uuid

  data_type: 'binary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 feed_uuid

  data_type: 'binary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 read

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 starred

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "account_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
    "feed_item_uuid",
    {
        data_type      => "binary",
        is_foreign_key => 1,
        is_nullable    => 0,
        size           => 16
    },
    "feed_uuid",
    {
        data_type      => "binary",
        is_foreign_key => 1,
        is_nullable    => 0,
        size           => 16
    },
    "read",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "starred",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</account_id>

=item * L</feed_uuid>

=item * L</feed_item_uuid>

=back

=cut

__PACKAGE__->set_primary_key( "account_id", "feed_uuid", "feed_item_uuid" );

=head1 RELATIONS

=head2 feed_item_uuid

Type: belongs_to

Related object: L<Munge::Schema::Result::FeedItem>

=cut

__PACKAGE__->belongs_to(
    "feed_item_uuid",
    "Munge::Schema::Result::FeedItem",
    { uuid          => "feed_item_uuid" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 feed_uuid

Type: belongs_to

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
    "feed_uuid", "Munge::Schema::Result::Feed",
    { uuid          => "feed_uuid" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-20 00:51:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g5+3zu+GJybU3+IKCj4mKQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
