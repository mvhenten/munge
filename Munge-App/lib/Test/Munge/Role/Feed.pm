use MooseX::Declare;

role Test::Munge::Role::Feed {

    use Cwd qw|realpath|;
    use URI;
    use Munge::Model::Feed;
    use Munge::Storage;
    use Munge::UUID;

    requires qw|create_test_account|;

    sub APPLICATION_PATH {
        my ($app_dir) = realpath(__FILE__) =~ m/(.+\/Munge-App\/)/;
        return $app_dir;
    }

    method create_test_feed_uri {
        my $filename = realpath(__FILE__);

        my $uri =
          URI->new( 'file:/' . APPLICATION_PATH() . '/t/resource/atom.xml' );
    }

    method create_test_feed {
        my $account = $self->create_test_account;
        my $uri     = URI->new( $self->create_test_feed_uri );
        $uri->query_form( q => rand %99999 );

        my $uuid = Munge::UUID->new( uri => $uri )->uuid_bin;

        my $storage = Munge::Storage->new(
            account     => $account,
            schema_name => Munge::Model::Feed->_schema_class(),
            schema      => $self->schema,
        );

        return Munge::Model::Feed->new(
            uuid     => $uuid,
            account  => $account,
            link     => $uri->as_string,
            _storage => $storage,
        );
    }

}
