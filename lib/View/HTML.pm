package View::HTML;

use strict;
use warnings;

use Moo;
use Types::Standard -types;

with 'MooX::Singleton';

use FindBin;
use Template;
use HTTP::Response;

has 'search_paths' => (
  is      => 'ro',
  isa     => ArrayRef[Str],
  lazy    => 1,
  default => sub { return ["$FindBin::Bin/templates"]; }
);

has 'engine' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    return Template->new({ INCLUDE_PATH => $self->search_paths });
  },
);

sub process {
  my ($self, $template, $view_model) = @_;

  
  my $content;
  open (my $content_fh, '>', \$content);
  unless ($self->engine->process("$template.tt", { Model => $view_model }, $content_fh)) {
    die "Template process failed: ", $self->engine->error(), "\n";
  }

  my $response = HTTP::Response->new();
  $response->code(200);
  $response->content_type('text/html');
  $response->content($content);
  return $response;
}

1;
