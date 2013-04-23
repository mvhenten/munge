#!/usr/bin/perl
use strict;
use warnings;

use MooseX::Declare;

=head1 NAME

Munge::Model::View::Feed

=head1 DESCRIPTION

Wrapper around Email::Send for simple emails

=head1 SYNOPSIS

    use Munge::Email;

    my $mail = Munge::Email->new(
        to      => 'someone@example.com',
        subject => 'test',
        body    => 'lorem ipsum sit amet'
    );

    $mail->submit();

    if( $mail->has_error ){
        # log errors
    }

=cut

class Munge::Email {
    use Try::Tiny;
    use Carp::Assert;
    use Email::Sender::Simple qw(sendmail);
    use Email::Simple;
    use Email::Simple::Creator;

    sub MUNGE_MAILER_ADDRESS { return 'munge-mailer@munge.eu' };

    has to => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has body => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has subject => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    has from => (
        is         => 'ro',
        isa        => 'Str',
        lazy_build => 1,
    );

    has error => (
        is        => 'ro',
        isa       => 'Str',
        predicate => 'has_error',
        writer    => '_set_error',
    );

    has _email => (
        is         => 'ro',
        isa        => 'Email::Simple',
        lazy_build => 1,
    );

    method _build_from {
        return MUNGE_MAILER_ADDRESS();
    }

    method _build__email {
        return Email::Simple->create(
            header => [
                From    => $self->from,
                To      => $self->to,
                Subject => $self->subject,
            ],
            body => $self->body,
        );

    }

    method submit() {
        try {
            sendmail( $self->_email );
        }
        catch {
            $self->_set_error($_);
        };
    };
}
