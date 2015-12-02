package Bootstrap;

use FindBin;
use ServiceLocator;

use Model::SearchEngine;
use View::HTML;

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
}

1;
