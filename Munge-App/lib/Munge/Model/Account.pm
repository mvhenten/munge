use MooseX::Declare;

=head1 NAME

Munge::Model::Account

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|Uri Account|;

class Munge::Model::Account {

    use Carp::Assert;
    use Crypt::SaltedHash;
    use Data::Dumper;
    use DateTime;
    use MIME::Base64 qw|encode_base64 decode_base64|;

    has account_rs => (
        is          => 'ro',
        isa         => 'Munge::Schema::Result::Account',
        lazy_build  => 1,
    );

    with 'Munge::Role::Schema';

    method _build_account_rs {
        return $self->resultset( 'Account' );
    }

    method create( Str $username, Str $plaintext_password ) {
        my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
        my $now = DateTime->now();

        $csh->add( $plaintext_password );
        my $salted = $csh->generate;

        my $verification_csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
        $verification_csh->add( join( ':', $salted, $plaintext_password, $now->epoch, $username )  );

        my $verification = $verification_csh->generate;

        my $rs = $self->resultset('Account')->create(
            {
                email       => $username,
                created     => $now,
                password    => $salted,
                verification => $verification,
            }
        )->insert();

        return $rs;
    }

    method load_from_account_id ( Int $account_id ) {
        my ( $rs ) = $self->resultset('Account')->find( $account_id );

        return $rs;
    }

    method load( Str $username ){
        my ( $rs ) = $self->resultset('Account')->search({ email => $username });

        return $rs;
    }

    method delete( Str $username ) {
        my ( $account ) = $self->resultset('Account')->search({ email => $username });

        return if not $account;

        $self->resultset('AccountFeedItem')->search({
            account_id     => $account->id,
        })->delete();

        $self->resultset('AccountFeed')->search({
            account_id     => $account->id,
        })->delete();

        $account->delete();

        return 1;
    }

    method find( HashRef $columns ){
        return if not $columns->{id};
        assert( defined( $columns->{id} ), 'columns have id');

        my ( $rs ) = $self->resultset('Account')->search({ id => $columns->{id} });

#        assert( defined( $rs ), 'there is an account' );

        return $rs;
    }

    method verificate ( Str $username, Str $plaintext_password, Str $base64_verification_code ) {
        my ( $account ) = $self->resultset('Account')->search({ email => $username });

        return 0 if not $account;

        my $verification = decode_base64( $base64_verification_code );
        return 0 if not ( $account->verification eq $verification );

        my $valid = Crypt::SaltedHash->validate( $verification,  join( ':', $account->password, $plaintext_password, $account->created->epoch, $username ) );
        return 0 if not $valid;

        $self->set_verified( $account );

        return 1;
    }

    method set_verified ( $account ) {
        $account->update({ verification => '' });
        return 1;
    }

    method validate ( Account $account, Str $plaintext_password ) {
        return 0 if not $account->verified;

        my $valid = Crypt::SaltedHash->validate( $account->password, $plaintext_password );

        return $valid;
    }

}
