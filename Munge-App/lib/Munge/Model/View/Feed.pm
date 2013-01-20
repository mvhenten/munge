use MooseX::Declare;
use MooseX::StrictConstructor;

=head1 NAME

Munge::Model::View::Feed

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|UUID Uri Account|;

class Munge::Model::View::Feed {
    use Data::Dumper;
    use Data::UUID;
    use DateTime;
    use URI;

    use Munge::Util qw|uuid_string|;
    use Munge::Types qw|UUID|;

    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method feed_view ( $uuid ) {
        my ( $item ) = $self->resultset('Feed')->search({ uuid => to_UUID( $uuid ), account_id => $self->account->id });

        return $self->_get_list_view( $item );
    }

    method all_feeds {
        my $items = $self->resultset('AccountFeed')->search(
            { 'me.account_id' => $self->account->id  },
            {
                prefetch => [ 'feed' ],
                join => [
                    'feed',
                ],
                order_by => { -desc => 'feed.title' },
             }
        );

        return [ map { $self->_get_list_view( $_ ) } $items->all ];
    }

    method _get_list_view ( $account_feed ) {
        my $feed = $account_feed->feed;
        
#        my $x = $account_feed->account_feed_items;
        
        return {
            $feed->get_inflated_columns,
            uuid_string => uuid_string( $feed->uuid ),
            title       => $feed->title || $feed->link,
            unread_items => $account_feed->unread_items->count() || 0,
        }
    }
}
