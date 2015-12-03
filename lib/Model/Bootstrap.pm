package Model::Bootstrap;

use FindBin;
use ServiceLocator;

use Model::Document;
use Model::SearchEngine;
use View::HTML;
use View::JSON;

sub setup {
  my ($class, $locator) = @_;
  $locator //= ServiceLocator->default();
  $locator->register('view', View::HTML->new());

  my $doc_path = "$FindBin::Bin/data/docs";
  my $index_path = "$FindBin::Bin/data/index";
  $locator->register('search-data-path', $doc_path);
  $locator->register('search-index-path', $index_path);
  my $engine = Model::SearchEngine->new({
                index_path  => $index_path,
                doc_path    => $doc_path,
               });
  $locator->register('search-engine',$engine);

  opendir my $documents_dir, $doc_path or die "$doc_path does not exist";
  my @documents = grep { $_ !~ m/^(?:\.||\.\.)$/ } readdir $documents_dir;
  foreach my $document_id (@documents){
    $engine->load_document(Model::Document->load($document_id));
  }

  # API registration
  $locator = ServiceLocator->in_namespace('api');
  $locator->register('view', View::JSON->new());  
}

1;
