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
        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;
        my $feed = Munge::Model::Feed->load( $uuid );

        if( not $feed ) {
            $feed = Munge::Model::Feed->new(
                link    => $uri->as_string,
                uuid    => $uuid,
                title   => $title,
                updated => DateTime->now->subtract( years => 10 ), # force update NOW!
            );
        }

        $feed->store();

        return $class->_subscribe_feed( $account, $feed );
    }

    method subscribe_feed( $class: Account $account, UUID $feed_uuid ) {
        my $feed = Munge::Model::Feed->load( $feed_uuid );
        return $class->_subscribe_feed( $account, $feed );
    }

    method unsubscribe_feed ( $class: Account $account, UUID $feed_uuid ) {
        my $feed = Munge::Model::Feed->load( $feed_uuid );

        my $subscription = $class->new(
            account => $account,
            feed    => $feed,
        );

        $subscription->delete();

        return;
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

    method delete {
        $self->resultset('AccountFeedItem')->search({
            feed_uuid     => $self->feed->uuid,
            account_id     => $self->account->id,
        })->delete();

        $self->resultset('AccountFeed')->search({
            feed_uuid     => $self->feed->uuid,
            account_id     => $self->account->id,
        })->delete();
    }

}
