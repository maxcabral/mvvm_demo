package ViewModel::Search;

use strict;
use warnings;

use Moo;
use Types::Standard -types;
use Types::Common::String -types;
use Types::Common::Numeric -types;

use ServiceLocator;

has 'engine' => (
  is        => 'ro',
  lazy      => 1,
  default   => sub { return ServiceLocator->default()->locate('search-engine'); },
  init_arg  => undef,
);

has 'q' => (
  is        => 'ro',
  isa       => Str,
);

has 'results' => (
  is        => 'rwp',
  isa       => ArrayRef,
  init_arg  => undef,
  lazy      => 1,
  predicate => 1,
  default   => sub { return []; },
);

has 'result_count' => (
  is        => 'rwp',
  isa       => PositiveOrZeroInt,
  init_arg  => undef,
  default   => sub { return scalar @{shift->results}; },
);

sub get_results {
  my ($self) = @_;
  my $res = $self->engine->search($self->q);
  if ($res){
    $self->_set_results($res);
    $self->_set_result_count(scalar @$res);
    return 1;
  }

  return 0;
}

sub get_display_results {
  my ($self) = @_;

  $self->get_results() unless $self->has_results;

  my @ret_val = map {
    $_->{short_text} = substr($_->text,0,100);
    $_
  } @{$self->results};

  return \@ret_val;
}

sub TO_JSON {
  my ($self) = @_;
  my @ret_val = map {
    my $hash_copy = { %{$_} };
    $hash_copy
  } @{$self->get_display_results};

  return { results => \@ret_val, };
}

1;
