package Munge::Email::Verification;

use Moose;

use strict;
use warnings;

use Dancer ':syntax';
use MIME::Base64 qw|encode_base64|;
use MooseX::Method::Signatures;
use Munge::Email;

with 'Munge::Role::Account';

sub _MAIL_BODY {
    my ( $verification_url ) = @_;

    my $body = <<"BODY"
Hello,

You've expressed interest in munge. Thanks.

Currently this software is in very early alpha, and I am looking for
contributors. That said, I use it on a daily basis for reading my
news.

The sourcecode is available from github:
http://github.com/mvhenten/munge

Meanwhile, feel free to play around on the dotcloud sandbox by
verifying your account:

$verification_url

Note: it may take some time for feeds to appear after an import, a
sync script runs every 5 minutes for now.

BODY
;
    return $body;
}



method submit {
    my $token = encode_base64( $self->account->verification );
    my $verification_uri =  uri_for( 'account/verify/' . $token );

    my $mail = Munge::Email->new(
        to      => $self->account->email,
        subject => '[MUNGE] Account verification for ' . $verification_uri->host,
        body    => _MAIL_BODY( $verification_uri ),
    );

    $mail->submit();

    if( $mail->has_error ){
        debug( 'ERROR SENDING MAIL ', $mail->error);
    }
    
    debug( 'EMAIL SEND TO ', $mail->to );

    
    my $copy = Munge::Email->new(
        to      => $ENV{MUNGE_SMTP_USERNAME},
        subject => '[COPY] Account verification for ' . $verification_uri->host,
        body    => _MAIL_BODY( $verification_uri ),
    );

    $copy->submit();
}
    

__PACKAGE__->meta->make_immutable;

1;
