package Model::Document;

use Moo;
use Types::Standard -types;
use Types::Common::String -types;

use Digest::Adler32;
use File::Slurp;
use File::Basename;
use JSON::XS;

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
  isa       => Maybe[NonEmptyStr],
);

sub load {
  my ($class, $path) = @_;
  my $data = read_file($path);
  my($filename, $dirs, $suffix) = fileparse($path);
  my $doc_name = $filename;

  $docname =~ s/"\.$suffix$"//i;

  my ($json,$text) = split("--$docname--",$data);
  my $meta = $encoder->decode($json);

  return Model::Document->new({
    %$meta,
    path  => $filename,
    text  => $text,
  });
}

sub save {
  my ($self, $path) = @_;
  $path //= $self->path;

  my $separator = $self->title;
  $separator =~ s/\s+/\-/g;

  my $json = $encoder->encode({ title => $title, source => $source });
  open (my $fh, '>', $path) or die $!;
  print $fh "$json\n";
  print $fh "--$separator--\n";
  print $fh $self->text;
  close $fh;

  return 1;
}

sub delete {
  my ($self) = @_;
  unlink $self->path;
}

1;
