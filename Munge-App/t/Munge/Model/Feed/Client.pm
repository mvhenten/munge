#http://feedburnerstatus.blogspot.com/feeds/posts/default

use MooseX::Declare;

class t::Munge::Model::Feed::Client {
    use Munge::Model::Feed::Client;
    use Test::Sweet;
    use DateTime;
    use URI;

    # won't hurt feedburner
    sub SAMPLE_FEED {
        return URI->new(
            'http://feeds.feedburner.com/feedburnerstatus?format=xml');
    }

    test feed_updated {
        my $dt = DateTime->now->subtract( 'years' => 1 );

        my $client = Munge::Model::Feed::Client->new(
            last_modified_since => $dt,
            feed_uri            => SAMPLE_FEED
        );

        ok( $client->updated, 'feed was updated less then one year ago' );
        ok( $client->success, 'feed was retrieved with success' );

        like( $client->content, qr{\Q<?xml\E}, 'feed looks like xml' );
    }

    test feed_not_updated {
        my $dt = DateTime->now->add( 'years' => 1 );

        my $client = Munge::Model::Feed::Client->new(
            last_modified_since => $dt,
            feed_uri            => SAMPLE_FEED
        );

        ok( ( not $client->updated ), 'feed was not updated in the future' );
    }

}
