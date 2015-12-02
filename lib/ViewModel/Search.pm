package ViewModel::Search;

use strict;
use warnings;

use Moo;
use Types::Standard -types;
use Types::Common::String -types;

use ServiceLocator;

has 'engine' => (
  is        => 'ro',
  lazy      => 1,
  default   => sub { return ServiceLocator->default()->locate('search-engine'); },
  init_arg  => undef,
);

has 'q' => (
  is        => 'ro',
  isa       => NonEmptyStr,
);

sub get_results {
  my ($self) = @_;
  return $self->engine->search($self->q);
}

1;
