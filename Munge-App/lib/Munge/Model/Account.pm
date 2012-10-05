use MooseX::Declare;

=head1 NAME

Munge::Model::Account 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Uri Account|;

class Munge::Model::Account {
    
    use Crypt::SaltedHash;
    use DateTime;

    has account_rs => (
        is          => 'ro',
        isa         => 'Munge::Schema::Result::Account',
        lazy_build  => 1,
    );
    
    with 'Munge::Role::Schema';
    
    method _build_account_rs {
        return $self->resultset( 'Account' );
    }
    
    method create ( Str $username, Str $plaintext_password ) {
        my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
        
        $csh->add( $plaintext_password );
        my $salted = $csh->generate;

        my $rs = $self->resultset('Account')->create(
            {
                email       => $username,
                created     => DateTime->now(),
                password    => $salted,
                verification => '',
            }
        )->insert();
   
        return $rs;
    }
    
    method load( Str $username ){
        my ( $rs ) = $self->resultset('Account')->search({ email => $username });

        return $rs;
    }    
    
    method validate ( Account $account, Str $plaintext_password ) {
        my $valid = Crypt::SaltedHash->validate( $account->password, $plaintext_password );
        
        return $valid;
    }

}
