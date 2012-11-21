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
        my $item = $self->resultset('Feed')->find({ uuid => to_UUID( $uuid ) });

        return $self->_get_list_view( $item );
    }

    method all_feeds {
        my $items = $self->resultset('Feed')->search(
            { 'me.account_id' => $self->account->id  },
            {
                join    => 'unread_items',
                order_by => { -desc => 'me.title' },
                distinct => 1,
                '+select' => [ { count => 'unread_items.read', -as => 'unread_items' } ],
            }
        );

        return [ map { $self->_get_list_view( $_ ) } $items->all ];
    }

    method _get_list_view ( $feed ) {
        return {
            $feed->get_inflated_columns,
            uuid_string => uuid_string( $feed->uuid ),
            title       => $feed->title || $feed->link,
        }
    }
}
