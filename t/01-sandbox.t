#!/usr/bin/perl
#
# vim: ft=perl 
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Gentoo-Probe.t'
# 
#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
use strict;
use Cwd;
use Carp;
use Gentoo::Probe;


#########################
package Test::Gentoo::Probe;
our(@ISA)=qw(Gentoo::Probe);
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self  = $class->SUPER::new(@_);
	return $self;
};
sub output {
	my $self = shift;
	local $_ = join("/", shift , shift);
	if ( @_ ) {
		my $pkg = $_;
		push(@{$self->{lines}}, map { $pkg . "-" . $_  } @_);
	} else {
		push(@{$self->{lines}}, $_ );
	};
};
sub run {
	my $self = shift;
	$self->{lines}=[];
	$self->SUPER::run(@_);
	return @{$self->{lines}};
};
#########################
package main;
my %data;
my $probe = Test::Gentoo::Probe->new(\%data);
is(ref $probe, q(Test::Gentoo::Probe), "Got right class");
