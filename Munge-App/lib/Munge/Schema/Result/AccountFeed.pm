use utf8;
package Munge::Schema::Result::AccountFeed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Munge::Schema::Result::AccountFeed

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

=head1 TABLE: C<account_feed>

=cut

__PACKAGE__->table("account_feed");

=head1 ACCESSORS

=head2 account_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 feed_uuid

  data_type: 'binary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "account_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "feed_uuid",
  { data_type => "binary", is_foreign_key => 1, is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</account_id>

=item * L</feed_uuid>

=back

=cut

__PACKAGE__->set_primary_key("account_id", "feed_uuid");

=head1 RELATIONS

=head2 account

Type: belongs_to

Related object: L<Munge::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "account",
  "Munge::Schema::Result::Account",
  { id => "account_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 feed_uuid

Type: belongs_to

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
  "feed_uuid",
  "Munge::Schema::Result::Feed",
  { uuid => "feed_uuid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-20 00:36:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L1QiNXjhF65fPCYZVFYf7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
  "feed",
  "Munge::Schema::Result::Feed",
  { uuid => "feed_uuid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
