use MooseX::Declare;

role Test::Munge::Role::Account {

    use Math::Base36 'encode_base36';

    requires 'resultset';

    has '_n_account' => (
        traits  => ['Counter'],
        is      => 'ro',
        isa     => 'Int',
        default => 0,
        handles => { _incr_n_accounts => 'inc' },
    );

    method create_test_account {
        my $email =
          sprintf( '%s_%d@example.com', encode_base36(time),
            $self->_n_account );

        my $rs = $self->resultset('Account')->create(
            {
                email        => $email,
                password     => 'lskdjflaskj93023',
                verification => '',
                verified     => 1,
            }
        )->insert();

        $self->_incr_n_accounts;

        return $rs;
    }

}
