package ViewModel::Submit;

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

has 'title' => (
  is        => 'ro',
  isa       => Maybe[Str],
);

has 'source' => (
  is        => 'ro',
  isa       => Maybe[Str],
);

has 'stored_source' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  lazy      => 1,
  init_arg  => undef,
  default   => sub { return shift->source//'User submitted'; },
);

has 'recipe' => (
  is        => 'ro',
  isa       => Maybe[Str],
);

=head2 Binding state

=cut

has 'added' => (
  is        => 'ro',
  isa       => Bool,
  default   => 0,
);

has 'error' => (
  is        => 'ro',
  isa       => Maybe[Str],
);

has 'error_code' => (
  is        => 'rwp',
  isa       => Str,
  predicate => 'has_error_code',
);

has 'error_message' => (
  is        => 'ro',
  isa       => Maybe[NonEmptyStr],
  init_arg  => undef,
  lazy      => 1,
  default   => sub {
    my ($self) = @_;
    if ($self->has_error_code && $self->error_code){
      if ($self->error_code =~ m/^(.*)_missing$/){
        if ($1){
          return "The $1 parameter is required";
        }
      } else {
        return "An unknown error has occured";
      }
    }
    return undef;
  },
);

sub can_add_to_index {
  my ($self) = @_;

  foreach my $req (qw(title recipe stored_source)){
    if (!$self->$req){
      $self->_set_error_code(sprintf('%s_missing',$req));
      return 0;
    }
  }

  return 1;
}

sub add_to_index {
  my ($self) = @_;
  return $self->engine->index_text($self->recipe, $self->title, $self->stored_source);
}

1;
