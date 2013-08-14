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

    method _format_datetime( $dt ) {
        return if not $dt;
        my $dtf = $self->schema->storage->datetime_parser;

        return $dtf->format_datetime( $dt );
    }
}
