package Model::SearchEngine;

use Moo;
use Types::Standard -types;
use Types::Common::String -types;

use Search::Indexer;

use Model::Document;

has 'engine' => (
  is      => 'ro',
  lazy    => 1,
  builder => '_build_engine',
);

sub _build_engine {
  my ($self) = @_;
  return new Search::Indexer(dir => $self->index_path, writeMode => 1);
}

has 'index_path' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  required  => 1,
);

has 'doc_path' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  required  => 1,
);

sub index_text {
  my ($self, $text, $title, $source) = @_;
  return $self->index_document(Model::Document->new({
    text    => $text,
    title   => $title,
    source  => $source,
    path    => $self->doc_path,
  }));
}

sub index_document {
  my ($self, $document) = @_;
  $self->engine->add($document->id,$document->text);
  $document->save();
  return 1;
}

sub remove_document {
  my ($self, $document) = @_;
  $self->engine->remove($document->id);
  $document->delete();
  return 1;
}

sub search {
  my ($self, $query) = @_;
  my $res = $self->engine->search($query);
  my $scores = $res->{scores};
  my @ret_val = map { Model::Document->load($_); } keys %$scores;
  return \@ret_val;
}

1;
