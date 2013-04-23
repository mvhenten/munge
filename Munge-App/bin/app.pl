#!/usr/bin/env perl
use Dancer;
use Munge::App;
use Carp::Assert;

assert( $ENV{google_api_client_id} );
assert( $ENV{google_api_client_secret} );

dance;
