package Munge::Env;
use strict;
use warnings;

use Carp::Assert;
use Exporter::Lite;

=head1 NAME
    Munge::Env
=head1 DESCRIPTION
    App constants defined trough ENV variables ( I think they are too sensitive for storing in git )
=cut

my @EXPORT_OK = qw|GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET|;

use constant GOOGLE_CLIENT_ID => $ENV{google_api_client_id};

use constant GOOGLE_CLIENT_SECRET => $ENV{google_api_client_secret};

warn '$ENV{google_api_client_id} NOT FOUND!' if not $ENV{google_api_client_id};
warn '$ENV{google_api_client_secret} NOT FOUND!'
  if not $ENV{google_api_client_secret};

1;
