use MooseX::Declare;

role Munge::Role::Schema {
    use Munge::Schema::Connection;

    sub resultset {
        my ( $self, @args ) = @_;

        return $self->schema->resultset(@args);
    }

    method schema {
        return Munge::Schema::Connection->schema();
    }

    method dbh {
        return $self->schema->storage->dbh;
    }
}
