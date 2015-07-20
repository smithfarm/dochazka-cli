#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::Dochazka::CLI' ) || print "Bail out!\n";
}

diag( "Testing App::Dochazka::CLI $App::Dochazka::CLI::VERSION, Perl $], $^X" );
