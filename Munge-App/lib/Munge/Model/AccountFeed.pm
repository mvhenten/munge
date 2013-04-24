use MooseX::Declare;

=head1 NAME

 Munge::Model::AccountFeed


=head1 DESCRIPTION

TODO

=head1 SYNOPSIS

TODO

=cut

class Munge::Model::AccountFeed {
    use Munge::Types qw|UUID|;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    has feed => (
        is       => 'ro',
        isa      => 'Munge::Model::Feed',
        required => 1,
    );

    method subscribe ( $class: Account $account, Uri $uri, $title='(Unknown Title)' ) {
        my $uuid = Munge::UUID->new( uri => $uri );
        my $feed = Munge::Model::Feed->load( $uuid );

        if( not $feed ) {
            $feed = Munge::Model::Feed->new(
                link    => $uri->as_string,
                uuid    => $uuid->uuid_bin,
                account => $account,
                title   => $title,
                updated => DateTime->now->subtract( years => 1 ), # force update NOW!
            );
        }

        $feed->store();

        return $class->_subscribe_feed( $account, $feed );
    }

    method subscribe_feed( $class: Account $account, UUID $feed_uuid ) {
        my $feed = Munge::Model::Feed->load( $feed_uuid );

        return $class->_subscribe_feed( $account, $feed );
    }

    method _subscribe_feed( $class: $account, $feed ) {
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

}
