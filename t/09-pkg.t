#!/usr/bin/perl
# vim:ft=perl
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
if 0; #$running_under_some_shell

	use Test::More skip_all => "lazy";

use modules qw(Data::Dumper strict Carp);
sub xopen($){
	local *FILE;
	my $res = open(FILE,$_[0]);
	return *FILE if $res;
	confess "open:",$_[0],":",$!,"\n";
}
sub suck($) {
	local *FILE;
	*FILE=xopen($_[0]);
	@_=<FILE>;
	return join("",@_) if close(FILE);
	confess "close:",$_[0],":",$!,"\n";
}
$SIG{__DIE__}=sub {
	print STDERR "Help!  am am about to die of: @_\n\n\n";
	confess @_;
};
$|++;
our ( $tests, @scripts, @dirs );
BEGIN {
	@dirs = map { "-I".$ENV{PWD}."/".$_; } qw(blib/lib blib/arch);
	$ENV{PORTDIR}=$ENV{PWD}."/t/sandbox/usr/portage";
	$ENV{VDB_DIR}=$ENV{PWD}."/t/sandbox/var/db/pkg";
	@scripts = qw(pkg pkg-files pkg-vi pkg-of);
	eval "use Test::More tests => ".(2*@scripts);
	die "$@" if "$@";
};
mkdir("tmp",0700);
confess "mkdir:tmp:$!\n" unless -d "tmp";

my $cnt = 0;
my $script;
for $script ( @scripts ) {
	print;
};
