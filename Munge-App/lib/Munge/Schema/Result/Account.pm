use utf8;
package Munge::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Munge::Schema::Result::Account

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

=head1 TABLE: C<account>

=cut

__PACKAGE__->table("account");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 254

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 42

=head2 verification

  data_type: 'varchar'
  is_nullable: 0
  size: 42

=head2 verified

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
  "email",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 42 },
  "verification",
  { data_type => "varchar", is_nullable => 0, size => 42 },
  "verified",
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

=head2 C<index_email>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("index_email", ["email"]);

=head1 RELATIONS

=head2 feed_items

Type: has_many

Related object: L<Munge::Schema::Result::FeedItem>

=cut

__PACKAGE__->has_many(
  "feed_items",
  "Munge::Schema::Result::FeedItem",
  { "foreign.account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feeds

Type: has_many

Related object: L<Munge::Schema::Result::Feed>

=cut

__PACKAGE__->has_many(
  "feeds",
  "Munge::Schema::Result::Feed",
  { "foreign.account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07023 @ 2012-10-28 23:54:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HpYx4WzODDpYEqDdOduaWA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
