#!/usr/bin/env perl
use inc::Module::Install 1.02;

name 'ExampleWeb';
all_from 'ExampleWeb.pl';

requires 'Web::Simple';
requires 'BerkeleyDB';
requires 'Search::Indexer';
requires 'Moo';
requires 'MooX::Singleton';
requires 'Types::Standard';

auto_install;
WriteAll;
