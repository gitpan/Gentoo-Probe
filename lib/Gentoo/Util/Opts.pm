package Gentoo::Util::Opts;
our($VERSION)=__VERSION__;
our(@ISA)=qw(Exporter);
use strict;$|=1;

use Gentoo::Util;
our %EXPORT_TAGS = ( all => [ qw(
	opts
) ] );
*EXPORT_OK=$EXPORT_TAGS{all};


my %switches;
my $usage;
sub parsefmt($){
	local $_ = shift;
	while(length) {
		my ($switch,$colons);
		($switch,$colons,$_) = m/^(.)(:?:?)(.*)/;
		confess "no optional args" if ( $colons eq '::' );
		confess ": is not a legal switch" if ( $switch eq ':' );
		$switches{$switch}=($colons eq ':'?'arg':'noarg');
	}
}
sub singleopt($@){
	my $text = 'single: "'.join('","',@{$_[$#_]}).'"';
	local $_ = shift;
	my $args = shift;
	my ($s, $type, @res,$t);
	while(length) {
		( $s, $_ ) = m/^(.)(.*)/;
		confess "illegal switch: $s (part of $s$_)" 
			unless ($type=$switches{$s});
		push(@res,"-$s");
		if ( $type eq 'noarg' )	{ next; };
		if ( length )			{ push(@res, $_);last; }
		if ( @$args )			{ push(@res, shift @$args);last; }
		confess "switch $s missing required arg";
	}
	return ( @res );
};
sub doubleopt($){
	die "usage" if $_[0] eq "help";
	die "version" if $_[0] eq "version";
	confess "long opts not supported!  double @_\n";
	();
}

sub opts($@&) {
	local $_;
	croak "Missing switch specifiers" unless @_;
	parsefmt(shift);
	my @nonopts;
	my @opts;
	while(@_) {
		confess "undef amongst the args?" unless defined($_ = shift);
		if 		( !s/^-// ) 		{ push(@nonopts,$_); next; }
		if		( !length )			{ push(@nonopts,'-'); next; }
		if		( !s/^-// ) 		{ push(@opts,singleopt $_, \@_);next; }
		if		( length )			{ push(@opts,doubleopt $_, \@_);next; }
		last;
	};
	return @opts, '--', @nonopts, @_;
}
1;
