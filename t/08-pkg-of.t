#!/usr/bin/perl
#   /* vim: set ft=perl ai tw=75: */
use Cwd;
use Test::More tests => 2;
use strict;
my %probe;
BEGIN {require "t/common.pl";};
my ($cwdlen) = length($main::portdir);
sub Test::Gentoo::Probe::process() {
};
runtest(qw(rfile pkg-of.lst base PkgOf));
