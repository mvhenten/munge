use MooseX::Declare;

=head1 NAME

Munge::Model::Account 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Uri Account|;
# use MooseX::Types::Moose qw|HashRef|;

class Munge::Model::Account {
    
    use Carp::Assert;
    use Crypt::SaltedHash;
    use Data::Dumper;
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
    
    method find( HashRef $columns ){
        assert( defined( $columns->{id} ), 'columns have id');
        
        my ( $rs ) = $self->resultset('Account')->search({ id => $columns->{id} });

        assert( defined( $rs ), 'there is an account' );
        
        return $rs;
    }

    method validate ( Account $account, Str $plaintext_password ) {
        my $valid = Crypt::SaltedHash->validate( $account->password, $plaintext_password );
        
        return $valid;
    }

}
