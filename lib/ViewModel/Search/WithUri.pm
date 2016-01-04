package ViewModel::Search::WithUri;

use strict;
use warnings;

use Moo;
extends 'ViewModel::Search';

use Data::Validate::URI qw(is_uri);
use URI;

around 'get_display_results' => sub {
  my $orig = shift;
  my $self = shift;

  my $res = $self->$orig;

  my @ret_val = map {
      if (is_uri($_->source)){
        $_->{source_as_uri} = URI->new($_->source);
      }
#      $_->{short_text} = substr($_->text,0,100);
      $_
  } @$res;

  return \@ret_val;
};


1;
