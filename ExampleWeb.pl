#!/usr/bin/env perl
package ExampleWeb;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Web::Simple;

use Data::Dumper;

use View::HTML;

has 'view' => (
  is    => 'ro',
  default => sub { return View::HTML->instance() },
);

sub dispatch_request {
  my $self = shift;

  return (
    'GET + /' => sub {
      return $self->to_ws_response($self->view->process('home'));
    },
    'GET + /search' => sub {
      return $self->to_ws_response($self->view->process('search'));
    },
    'GET + /submit' => sub {
      return $self->to_ws_response($self->view->process('submit'));
    },
    'POST + /submit' => sub {
      return $self->redirect("/submit");
    },
    '' => sub {
      [ 405, [ 'Content-type', 'text/plain' ], [ 'Method not allowed' ] ]
    },
  );
}

sub to_ws_response {
  my ($self, $response, $code, $headers) = @_;
  my $content;

  if (ref $response && ref $response eq 'HTTP::Response'){
    $content  = $response->content;
    $code     //= $response->code;
    $headers  //= [$response->headers->flatten]
  } else {
    $content  = $response;
    $code     //= 200;
    $headers  //= [ 'Content-type', 'text/plain' ];
  }
  
  return [ $code, $headers, [ $content ] ];
}

sub redirect {
  my ($self, $url, $code) = @_;
  $code //= 302;

  return [
           $code,
           [ 'Content-type', 'text/html', 'Location', $url ],
           [ sprintf('<html><body>Please follow <a href="%s">this link</a>.</body></html>',$url) ]
         ];

}

ExampleWeb->run_if_script;
