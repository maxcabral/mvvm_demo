#!/usr/bin/env perl
package ExampleWeb;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Web::Simple;

sub dispatch_request {
  GET => sub {
    [ 200, [ 'Content-type', 'text/plain' ], [ 'Hello world!' ] ]
  },
  '' => sub {
    [ 405, [ 'Content-type', 'text/plain' ], [ 'Method not allowed' ] ]
  }
}

ExampleWeb->run_if_script;
