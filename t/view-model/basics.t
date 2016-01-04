#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Try::Tiny;

use ViewModel::Search;
use ViewModel::Submit;

my $vm = ViewModel::Submit->new();

is($vm->can_add_to_index(),0,"Validation logic indicates we Can't add an empty document");

my $res = try {
  $vm->add_to_index();
  return 0;
} catch {
  return 1;
};

ok($res,"Can't add an empty document");

ok($vm->has_error_code,'Error code is set');
cmp_ok($vm->error_code,'eq','title_missing','Error code is "title_missing"');
ok($vm->error_message,'Error message is a valid value');

done_testing();

1;
