#!/usr/bin/perl -w
#   /* vim: set ft=perl ai tw=75: */
BEGIN {require "t/common.pl";};

use Cwd;
use Test::More tests => 2;
use strict;
my ($cwdlen) = length($main::portdir);
sub Test::Gentoo::Probe::process() {
	s{^$main::portdir}{};
};
runtest(base=>'Pkg',rfile=>'ebuilds.lst',builds=>1);
