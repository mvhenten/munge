use MooseX::Declare;

class Munge::Model::Feed {

    with 'Munge::Role::Schema';

    has account => (
        is       => 'ro',
        isa      => 'Munge::Schema::Result::Account',
        required => 1,
    );

    #method create (  ) {
    #
    #
    #}

}
