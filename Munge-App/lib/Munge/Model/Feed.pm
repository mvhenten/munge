use MooseX::Declare;

=head1 NAME

Munge::Model::Feed 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

class Munge::Model::Feed {
    use URI;

    use Munge::Model::Feed::Client;
    use Munge::Model::Feed::Parser;

    has feed_resultset => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Feed',
        required => 1,
        writer  => '_set_feed_resultset',
        handles  => [
            qw|
              account_id
              created
              description
              id
              link
              title
              updated
              feed_items
              |
        ],
    );

    has feed_uri => (
        is         => 'ro',
        isa        => 'URI',
        lazy_build => 1,
    );

    has _feed_client => (
        is         => 'ro',
        isa        => 'Munge::Model::Feed::Client',
        lazy_build => 1,
    );

    has _feed_parser => (
        is         => 'ro',
        isa        => 'Munge::Model::Feed::Parser',
        lazy_build => 1,
    );

    has _item_x_bool => (
        traits     => ['Hash'],
        is         => 'ro',
        isa        => 'HashRef',
        lazy_build => 1,
        clearer     => '_clear_item_x_bool',
        handles    => { _item_exists => 'exists' }
    );

    method _build_feed_uri {
        return URI->new( $self->link );
    }

    method _build__feed_parser {
        return Munge::Model::Feed::Parser->new(
            content => $self->_feed_client->content );
    }

    method _build__feed_client {
        return Munge::Model::Feed::Client->new(
            feed_uri            => $self->feed_uri,
            last_modified_since => $self->updated,
        );
    }

    method _build__item_x_bool {
        my $ug = new Data::UUID;
        
        my @hex_uuid = map { $ug->to_string( $_->uuid ) } $self->feed_items;
        my %lookup = map { $_ => 1 } @hex_uuid;
        
        return \%lookup;
    }

    method synchronize {
        return unless $self->_feed_client->updated;
        return unless $self->_feed_client->success;
        
        if( not $self->_feed_parser->xml_feed ){
            warn "Cannot parse feed: " . $self->feed_uri;
            return;
        }
        
        for my $item ( $self->_feed_parser->items ) {
            #warn $item->uuid;
            #warn Dumper( $self->_item_x_bool );
            if ( not $self->_item_exists( $item->uuid ) ) {
                $self->_create_item($item);
            }
        }

        $self->title( $self->_feed_parser->title );
        $self->description( $self->_feed_parser->description || '' );
        
        $self->_update();
    }
    
    method _update {
        use Data::Dumper;
        $self->feed_resultset->update();
        # warn Dumper( $self->feed_resultset );
        $self->feed_items->clear_cache();
        
    
        #my $updated_rs = $self->feed_resultset->get_from_storage;
        ##
        #$self->_set_feed_resultset( $updated_rs );
        $self->_clear_item_x_bool();        
    }

    method _create_item( $item ) {        
        $self->feed_items->create(
                {
                    account_id  => $self->account_id,
                    feed_id     => $self->id,
                    uuid        => $item->uuid_bin,
                    link        => $item->link,
                    title       => $item->title,
                    description => $item->content,
                }
        );

    }

}
