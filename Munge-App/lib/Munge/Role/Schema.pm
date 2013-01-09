use MooseX::Declare;

role Munge::Role::Schema {
    use Munge::Config;
    use Munge::Schema;

    {
        my $schema;

        sub resultset {
            my ( $self, @args ) = @_;

            return $self->schema->resultset(@args);
        }

        method schema {
            if( $schema and not $schema->storage->connected ){
                $schema = undef;
            }
            
            if ( not $schema ) {
                $schema = Munge::Schema->connect(
                    Munge::Config::DSN(),
                    Munge::Config::DB_USER(),
                    Munge::Config::DB_PASSWORD(),
                    {
                        RaiseError        => 1,
                        AutoCommit        => 1,
                        mysql_enable_utf8 => 1,
                        quote_names       => 1
                    }
                );

            }

            return $schema;
        }
    }
}
