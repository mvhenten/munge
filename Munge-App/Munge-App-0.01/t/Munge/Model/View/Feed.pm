use MooseX::Declare;

use strict;
use warnings;

class t::Munge::Model::View::Feed {
    use Munge::Model::View::Feed;
    use Test::Sweet;

    with 'Test::Munge::Role::Schema';
    with 'Test::Munge::Role::Account';
    with 'Test::Munge::Role::Feed';

    test test_all_feeds {
        my $view = Munge::Model::View::Feed->new( schema => $self->schema );

        #        my $account = $self->create_test_account;

    }

}
