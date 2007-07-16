#!/usr/bin/perl
# vim:ft=perl
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
if 0; #$running_under_some_shell

use Gentoo::Config;
use Data::Dumper;
use Carp;
use strict;
$SIG{__DIE__}=sub {
	print STDERR "\n\nHelp!  am am about to die of: @_\n\n\n";
	confess @_;
};
our ( $tests, @scripts, %failures );
BEGIN {
	$tests = 2;
	@scripts = qw(pkg pkg-files pkg-of);
	sub fail_map(@){
		my %res = map { ( $_, 0 ) } @scripts;
		for ( @_ ) {
			$res{$_}++;
		};
		return \%res;
	}
	%failures = (
		"-- -info" => 	 fail_map(qw()),
		"-u -- -info" => fail_map(qw(pkg-files pkg-of)),
		"-b -- -info" => fail_map(qw(pkg-of pkg-files)),
		"--help" => 	 fail_map(qw()),
		"--version" => 	 fail_map(qw()),
	);
	$tests *= (@scripts);
	$tests *= (keys %failures);
};
use Test::More tests => $tests;

system("rm -fr tmp") if -e "tmp";
die "tmp is immortal.  There can be only one." if -e "tmp";
mkdir "tmp", 0700 or confess "I just needed it for a while!\nmkdir:tmp:$!\n";

my $dirs = join(" ", map { "-I".$ENV{PWD}."/".$_; } qw(blib/lib blib/arch));

my $cnt = 0;
for my $args ( sort keys %failures ) {
	local %failures = %{$failures{$args}};
	++$cnt;
	for my $script (@scripts) {
		my ( $ofile, $efile ) = map { $_ . $script . "." . $cnt } qw( tmp/stdout. tmp/stderr. );
		my $cmd = "/usr/bin/perl $dirs ./blib/bin/$script >$ofile 2>$efile  $args";
		system $cmd;
		my ($res,$exp)=( 0, ($failures{$script})?1:0);
		$res++ if $?;
		is($res,$exp,"exit code ($cmd)");
		my @lines = grep /./, qx(cat $efile);
		if ( !$res ) {
			ok(@lines==0,"$efile empty ($cmd)");
		} else {
			ok(@lines>=1,"$efile not empty ($cmd)");
		};
	};
};
