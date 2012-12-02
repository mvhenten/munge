use MooseX::Declare;

=head1 NAME

Munge::Model::View::FeedItem

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Feed Account|;

class Munge::Model::View::FeedItem {

    with 'Munge::Role::Schema';

    use DateTime;
    use Munge::Types qw|UUID|;
    use Data::Dumper;
    use Munge::Util qw|strip_html string_ellipsize sanitize_html|;

    has account => (
        is => 'ro',
        isa => 'Munge::Schema::Result::Account',
        required => 1,
    );

    method format_datetime ( $dt ) {
        my $dtf = $self->schema->storage->datetime_parser;

        return $dtf->format_datetime( $dt );
    }

    method today {
        my $yesterday = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                'me.account_id' => $self->account->id,
                'me.created'    => { '>=', $yesterday },
            },
            {
                prefetch => 'feed',
                join => 'feed',
                order_by   => { -desc => 'me.issued' },
                rows       => 40,
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method yesterday {
        my $min_age = $self->format_datetime( DateTime->today()->subtract('days' => 2) );
        my $max_age = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                'me.account_id' => $self->account->id,
                'me.created'    => { '>=', $min_age },
                'me.created'    => { '<=', $max_age },
            },
            {
                prefetch => 'feed',
                join => 'feed',
                order_by   => { -asc => 'me.issued' },
                rows       => 10,
            }
        );

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method older {
        my $max_age = $self->format_datetime( DateTime->today()->subtract('days' => 1) );

        my $items = $self->resultset('FeedItem')->search(
            {
                'me.account_id' => $self->account->id,
                'me.created'    => { '<=', $max_age },
            },
            {
                prefetch => 'feed',
                join => 'feed',
                order_by   => { -asc => 'me.issued' },
                rows       => 25,
            }
        );

    }


    method list_account( Account $account, Int $page=1 ){
        my $items = $self->resultset('FeedItem')->search(
            { account_id => $account->id },
            {
                prefetch => 'feed',
                join => 'feed',
                order_by   => { -asc => 'issued' },
                page       => $page,
                rows       => 25,
            }
        );

        return [ $items->all() ];
    }

    method list( Str $uuid, Int $page=1 ){
        my $items = $self->resultset('FeedItem')->search({
            'feed.uuid' => to_UUID( $uuid ),
            'feed.account_id' => $self->account->id
        },
        {
            prefetch => 'feed',
            join => 'feed',
            order_by   => { -desc => 'me.issued' },
        });

        return [ map { $self->_create_list_view( $_ ) } $items->all() ];
    }

    method get_item( Str $uuid ){
        my $search = $self->resultset('FeedItem')->search({
            'me.uuid' => to_UUID( $uuid ),
            'feed.account_id' => $self->account->id
        },
        {
            prefetch => 'feed',
            join => 'feed',
            order_by   => { -asc => 'me.issued' },
        });

        my ( $item ) = $search->all();
        return $item ? $self->_create_list_view( $item ) : undef;
    }

    method _create_list_view ( $feed_item ) {
        my $ug = Data::UUID->new();

        return {
            $feed_item->get_inflated_columns(),
            date                => $feed_item->issued->ymd,
            feed_description    => $feed_item->feed->description,
            feed_title          => $feed_item->feed->title,
            feed_uuid           => $feed_item->feed->uuid,
            feed_uuid_string    => $ug->to_string( $feed_item->feed->uuid ),
            uuid_string         => $ug->to_string( $feed_item->uuid ),
          }
    }


}
