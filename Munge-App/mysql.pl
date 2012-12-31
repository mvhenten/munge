#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';

use DBIx::Class::Admin;
use DBI;
use Munge::Schema;
use Munge::Config;

my $database;
my $dbh;

sub DATABASE_NAME {
    return 'munge';
}

sub DSN {
    return sprintf( 'DBI:mysql:host=%s;port=%s;', Munge::Config::HOST(), Munge::Config::PORT() );
}

sub deploy_database {
    my $admin = DBIx::Class::Admin->new(
        schema_class => 'Munge::Schema',
        sql_dir      => 'sql',
        connect_info => {
            dsn      => Munge::Config::DSN(),
            user     => Munge::Config::DB_USER(),
            password => Munge::Config::DB_PASSWORD(),
        },
    );

    $admin->deploy();
}

sub create_database {
    for( 0 ... 10 ){
        STDOUT->printflush(".");

        $dbh = DBI->connect( DSN(), Munge::Config::DB_USER(), Munge::Config::DB_PASSWORD(), {RaiseError=>0,PrintError=>0});
        last if(defined $dbh);

        sleep(1);
    }

    return 0 if $dbh->selectrow_array('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?', undef, DATABASE_NAME() );

    die 'Cannot connect' unless $dbh;

    printf( qq|initializing database "%s"|, DATABASE_NAME() );
    $dbh->func('createdb', DATABASE_NAME(), 'admin' );

    return 1;
}

printf( qq|initializing database "%s"|, DATABASE_NAME() );

if( create_database() ){
    print "\n";
    print "Deploying database " . DATABASE_NAME() . "\n";
    deploy_database();
}

print "\n";
