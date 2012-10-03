use MooseX::Declare;

=head1 NAME

Munge::Model::Feed 

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

class Munge::Model::Feed {

    has feed_resultset => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Feed',
        required => 1,
        handles  => [qw|id title description|],
    );
}
