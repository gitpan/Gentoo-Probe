#!/usr/bin/perl
#   /* vim: set ft=perl ai tw=75: */
use Cwd;
use Test::More tests => 2;
use strict;
my %probe;
BEGIN {require "t/common.pl";};
sub Test::Gentoo::Probe::process() {
	s#/+#/#g;
};
runtest(qw(
	base Pkg
	rfile installed.lst
	installed  1
));
