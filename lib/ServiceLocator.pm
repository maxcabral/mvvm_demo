package ServiceLocator;

use strict;
use warnings;

use Moo;
use Types::Standard -types;

our %instances;

has 'namespace' => (
  is        => 'ro',
  isa       => Maybe[Str],
  default   => undef,
);

has '_data' => (
  is        => 'ro',
  isa       => HashRef,
  init_arg  => undef,
  default   => sub { return {}; },
);

sub locate {
  my ($self, $key) = @_;
  return $self->_data->{$key};
}

sub register {
  my ($self, $key, $instance) = @_;
  $self->_data->{$key} = $instance;
}

sub default {
  my ($class) = @_;
  return $class->in_namespace('');
}

sub in_namespace {
  my ($class, $key) = @_;
  $key //= '';
  my $locator = $instances{$key};
  unless ($locator){
    $locator = ServiceLocator->new( namespace => $key);
    $instances{$key} = $locator;
  }
  return $locator;
}

$instances{''} = ServiceLocator->new();

1;
