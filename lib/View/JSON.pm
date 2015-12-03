package View::JSON;

use strict;
use warnings;

use Moo;

use JSON::XS;
use HTTP::Response;

has 'serializer' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    return JSON::XS->new()->allow_blessed()->convert_blessed()->utf8()->pretty();
  },
);

sub process {
  my ($self, $template, $view_model) = @_;

  my $content = $self->serializer->encode($view_model);
  
  my $response = HTTP::Response->new();
  $response->code(200);
  $response->content_type('text/html');
  $response->content($content);
  return $response;
}

1;
