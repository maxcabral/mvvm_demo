package Model::SearchEngine;

use Moo;
use MooX::Singleton;
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
  return new Search::Indexer(dir => $self->indexes, writeMode => 1);
}

has 'indexes' => (
  is    => 'ro',
  isa   => NonEmptyStr
);

has 'documents' => (
  is    => 'ro',
  isa   => NonEmptyStr
);

sub index_text {
  my ($self, $text, $title, $source) = @_;
  return $self->index_document(Model::Document->new({
    text    => $text,
    title   => $title,
    source  => $source,
  });
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
  return $self->engine->search($query);
}

1;
