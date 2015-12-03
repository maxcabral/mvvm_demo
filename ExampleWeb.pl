#!/usr/bin/env perl
package ExampleWeb;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Web::Simple;

use Module::Load;
use Data::Dumper;

use Model::Bootstrap;
use ServiceLocator;
use Try::Tiny;
use URI;

our $locator = ServiceLocator->default();
Model::Bootstrap->setup($locator);

sub dispatch_request {
  my $self = shift;

  return (
    'GET + /' => sub {
      return $self->to_ws_response($locator->locate('view')->process('home'));
    },
    'GET + /search + ?*' => sub {
      my $vm = $self->handle_search_request(\%_);
      return $self->to_ws_response($locator->locate('view')->process('search', $vm));
    },
    'GET + /api/search + ?*' => sub {
      my $vm = $self->handle_search_request(\%_);
      return $self->to_ws_response(ServiceLocator->in_namespace('api')
                                                 ->locate('view')
                                                 ->process('search', $vm));
    },
    'GET + /submit + ?*' => sub {
      my $vm = bind_params('ViewModel::Submit',\%_);

      return $self->to_ws_response($locator->locate('view')->process('submit', $vm));
    },
    'POST + /submit + %*' => sub {
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
      
      my $redirect = URI->new();
      $redirect->path("/submit");
      $redirect->query_form({
        added => $added,
        error_code => $error
      });
      return $self->redirect($redirect->as_string());
    },
    '' => sub {
      [ 405, [ 'Content-type', 'text/plain' ], [ 'Method not allowed' ] ]
    },
  );
}

sub handle_search_request {
  my ($self, $params) = @_;
  my $vm_class = $params->{no_uri} ? 'ViewModel::Search' : 'ViewModel::Search::WithUri';

  my $vm = bind_params($vm_class,$params);
  unless ($vm->get_results()){
    # Maybe you want to handle the zero result case here
  }

  return $vm;
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
  load $package;
  return try { return $package->new($params) } catch { warn $_; return undef; };
}

ExampleWeb->run_if_script;
