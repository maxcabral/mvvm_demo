#!/usr/bin/env perl
package ExampleWeb;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Web::Simple;

use Module::Load;
use Data::Dumper;

use Bootstrap;
use ServiceLocator;
use Try::Tiny;

our $locator = ServiceLocator->default();
Bootstrap->setup($locator);

sub dispatch_request {
  my $self = shift;

  return (
    'GET + /' => sub {
      return $self->to_ws_response($locator->locate('view')->process('home'));
    },
    'GET + /search' => sub {
      return $self->to_ws_response($locator->locate('view')->process('search'));
    },
    'GET + /submit + ?*' => sub {
      my $vm = bind_params('ViewModel::Submit',\%_);

      return $self->to_ws_response($locator->locate('view')->process('submit', $vm));
    },
    'POST + /submit + ?*' => sub {
      my $vm = bind_params('ViewModel::Submit',\%_);
      my $error;
      my $added = 0;

      if ($vm){
        if ($vm->can_add_to_index){
          $added = try {
            return $vm->add_to_index();
          } catch {
            warn $_;
            $error = "indexing";
            return 0;
          };
        } else {
          $error = $vm->error_code;
        }
      } else {
        $error = "missing-params";
      }
      
      return $self->redirect("/submit?added=$added&error_code=$error");
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

sub bind_params {
  my ($package, $params) = @_;
  $params //= {};
use Data::Dumper;
warn Dumper $params;
  load $package;
  return try { return $package->new($params) } catch { warn $_; return undef; };
}

ExampleWeb->run_if_script;
