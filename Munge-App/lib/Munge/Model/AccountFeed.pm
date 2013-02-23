package Munge::Model::AccountFeed;
use Moose;

use strict;
use warnings;

use MooseX::Method::Signatures;

# use MooseX::Declare;

=head1 NAME

 Munge::Model::AccountFeed

=head1 DESCRIPTION

TODO

=head1 SYNOPSIS

TODO

=cut

with 'Munge::Role::Schema';
with 'Munge::Role::Account';

has feed => (
    is       => 'ro',
    isa      => 'Munge::Model::Feed',
    required => 1,
);

method subscribe ( $class: Account $account, Uri $uri ) {
    my $uuid = Munge::UUID->new( uri => $uri );

    my $feed = Munge::Model::Feed->new(
        link    => $uri->as_string,
        uuid    => $uuid->uuid_bin,
        account => $account,
    );

    $feed->store();
    
    my $subscription = $class->new(
        account => $account,
        feed    => $feed,
    );
    
    $subscription->store();
    
    return $subscription;
}

method store {
    my $row = $self->resultset('AccountFeed')->update_or_create({
        feed_uuid     => $self->feed->uuid,
        account_id     => $self->account->id,
    });

    return; 
}


__PACKAGE__->meta->make_immutable;

1;
