use MooseX::Declare;
use MooseX::StrictConstructor;

=head1 NAME

Munge::Model::View::Feed

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Munge::Types qw|UUID Uri Account|;

class Munge::Model::View::Feed {
    use Data::Dumper;
    use Data::UUID;
    use DateTime;
    use URI;

    use Munge::Types qw|UUID|;
    use Munge::UUID;
    
    with 'Munge::Role::Schema';
    with 'Munge::Role::Account';

    method all_feeds {
        my @feeds   = map { $self->_process_feed({ $_->get_inflated_columns() }) }  $self->account->feeds;

        return \@feeds;
    }
    
    method _process_feed ( HashRef $feed ) {
        my $ug = Data::UUID->new();
        
        $feed->{uuid_string} = $ug->to_b64string( $feed->{uuid} );

        return $feed;
    }
    

}