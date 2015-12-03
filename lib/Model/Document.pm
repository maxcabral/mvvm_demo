package Model::Document;

use Moo;
use Types::Standard -types;
use Types::Common::String -types;

use Digest::Adler32;
use File::Slurp;
use File::Basename;
use JSON::XS;

use ServiceLocator;

our $encoder = JSON::XS->new()->pretty()->utf8();

has 'id' => (
  is        => 'ro',
  isa       => Int,
  lazy      => 1,
  builder   => '_build_id',
);

sub _build_id {
  my ($self) = @_;
  my $a32 = Digest::Adler32->new;
  $a32->add($self->text);
  return unpack('I',$a32->digest);  
}

has 'title' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  required  => 1,
);

has 'text' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  required  => 1,
);

has 'source' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  required  => 1,
);

has 'path' => (
  is        => 'ro',
  isa       => NonEmptyStr,
  lazy      => 1,
  builder   => '_build_path',
);

sub _build_path {
  return ServiceLocator->default()->locate('search-data-path');
}

sub load {
  my ($class, $id, $path) = @_;
  $path //= _build_path();
  my $data = read_file("$path/$id");

  my ($json,$text) = split("--$id--",$data);
  my $meta = $encoder->decode($json);

  return Model::Document->new({
    %$meta,
    path  => $path,
    text  => $text,
  });
}

sub save {
  my ($self, $path) = @_;
  $path //= $self->path;

  my $id = $self->id;

  my $json = $encoder->encode({
    id      => $id,
    title   => $self->title,
    source  => $self->source
  });

  open (my $fh, '>', "$path/$id") or die $!;
  print $fh "$json\n";
  print $fh "--$id--\n";
  print $fh $self->text;
  close $fh;

  return 1;
}

sub delete {
  my ($self) = @_;
  unlink sprintf("%s/%s",$self->path,$self->id);
}

1;
