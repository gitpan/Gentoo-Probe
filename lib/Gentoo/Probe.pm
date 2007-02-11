package Gentoo::Probe;
our ($VERSION) = q(1.0.2);
#our(@ISA)=
use strict; $|=1;

sub import { goto \&Exporter::import };
use Gentoo::Util;
use Gentoo::Config;
use Cwd;
our(@mods);
my (%defs) = (
			'uninstalled'  =>  0,
			'installed'    =>  0,
			'case'         =>  1,
			'versions'     =>  0,
			'builds'       =>  0,
			'verbose'      =>  1,
			'latest'       =>  0,
			'pats'         =>  [],
			'cfgdir'       =>  undef,
			'portdir'      =>  undef,
			'vdb_dir'      =>  undef,
);
my $cfg;
sub cfg {
	$cfg || ($cfg = new Gentoo::Config);
};
sub output {
	my $self = shift;
	print @_, "\n";
};
sub portdir  {
	$_[0]->{portdir};
};
sub overdir {
	$_[0]->{overdir};
};
sub vdb_dir {
	$_[0]->{vdb_dir} || "/var/db/pkg";
};
sub new {
	local $_;
	my $class = shift;
	my $passed = shift;
	confess "usage: new Gentoo::Probe(\%parms) [got: ", $passed, "]" unless ref $passed;
	my %data = ( %defs, %{$passed} );
	my $self=\%data;
	bless($self,$class);
	$self->gen_methods();
	for($self->{portdir}) {
		$_= cfg()->get(qw(PORTDIR)) unless defined;
	};
	for($self->{overdir}) {
		$_= cfg()->get(qw(PORTDIR_OVERLAY),"") unless defined;
	};
	for ( $self->{portdir}, $self->{vdb_dir} ) {
		next unless defined;
		$_ = getcwd()."/".$_ unless m{^/};
		$_.="/";
		s{/[./]*/}{/}g;
	};
	my $pats = $data{pats};
	if ( !defined($pats) ) {
		$pats = $data{pats} = [ ];
	} elsif ( ref $pats eq 'ARRAY' ) {
		# all is well
	} elsif ( ref $pats ) {
		die "got a ", ref $pats, " as pats\n";
	} else {
		$pats = $data{pats} = [ $pats ];
	}
	for ( @$pats ) {
		$_ = qr($_);
	}
	confess "\$pats should be an array ref!" unless ref $pats eq 'ARRAY';

	$self->{versions}=1 if $self->builds() || $self->latest();
	unless ( $self->{installed} || $self->{uninstalled} ) {
		$self->{installed} = $self->{uninstalled} = 1
	};
	return $self;
};
sub ls_vers {
	local *DIR;
	my $self = shift;
	my $cat = shift;
	my $pkg = shift;
	# Damn package name fits version pattern.
	warn "got canna!" if $pkg eq "canna";
	my @res;
	my $dir = join("/", $cat, $pkg );
	if ( $self->uninstalled() ) {
		warn "opendir:$dir:$!\n" && return () unless opendir(DIR,$dir);
		for ( readdir(DIR) ){
			my $xpkg = substr($_,0,length($pkg)+1,"");
			next unless $xpkg eq $pkg."-";
			next unless s/\.ebuild$//;

			push(@res,$_);
		};
		closedir(DIR);
	} else {
		for ( glob("$dir*") ){
			my $xdir = substr($_,0,length($dir)+1,"");
			next unless $xdir eq $dir."-";
			push(@res,$_);
		};
	}
	return sort @res;
};
sub ls_pkgs($$){
	return sort map {
		if ( /^canna-2ch/ ) {
			s/-2ch-[0-9].*/-2ch/;
		} elsif ( /^font-adobe-\d+dpi/ ) {
			s/dpi-[0-9].*/dpi/;
		} else {
			s/-[0-9].*//;
		};
		$_;
	} ls_dirs( $_[0],$_[1] );
};
sub ls_dirs($$){
	my ( $dir, $allowfail ) = (shift,shift);
	if ( opendir(my $DIR, $dir) ) {
		my @x= readdir($DIR);
		@x=grep {
			$_ ne '.' && $_ ne 'CVS' && $_ ne '..' && -d $dir."/".$_
		} @x;
		return sort @x;
	};
	return () if $allowfail;
	confess "opendir:$dir:$!\n";
};
sub search_dir {
	my $self = shift;
	if ( $self->uninstalled() ) {
		return $self->portdir();
	} else {
		return $self->vdb_dir();
	};
};
sub accept($$$@) {
	my ( $self, $cat, $pkg, @vers ) = @_;

	splice(@vers,0,-1) if ( $self->latest() );
	if ( $self->builds() ) {
		$cat = join("/", $self->portdir(),$cat);
		for ( @vers ) {
			$self->output(join("/",$cat,$pkg,$pkg."-".$_ .".ebuild"));
		};
	} elsif ( $self->versions() ) {
		for (@vers ) {
			$self->output($cat."/".$pkg."-".$_);
		};
	} else {
		$self->output($cat."/".$pkg);
	};
};
sub not_installed($$$){
	my ( $self, $cat, $pkg ) = @_;
	my $globspec = $self->vdb_dir()."/$cat/$pkg-[0-9]*/.";
	return !glob($globspec);
};
sub check_pats($@){
	my $self = shift;
	local $_ = shift;
	return 1 unless @_;
	for my $re ( @_ ) {
		#	confess "internal error" if ref $re ne 'Regexp';
		return 1 if /$re/;
	};
	return 0;
};
sub prime_seen(\%$){
	our(%seen);
	local(*seen)=shift;
	$seen{$_}++ for ( ls_pkgs(shift,1) )
}
sub run($) {
	my $self=shift;
	my $base = $self->search_dir();
	my $inst = $self->installed();
	my $unin = $self->uninstalled();
	my $idir = $self->vdb_dir();
	my $pkg;
	my $ver;
	my $cat;
	my @pats = @{$self->{pats}};

	die unless $inst || $unin;

	xchdir($base);
	my @cats = ls_dirs(".",0);
	for $cat ( @cats ) {
		next unless $cat =~ /-/;
		my %seen;
		prime_seen(%seen,$idir."/".$cat) unless $inst;
		my @pkg = grep { !$seen{$_}++ } ls_pkgs($cat,0);

		for $pkg ( @pkg ) {
			my $qua = $cat."/".$pkg;
			next unless $self->check_pats( $cat . "/" . $pkg , @pats );
			if ( $self->versions() ) {
				my @builds = $self->ls_vers($cat,$pkg);
				$self->accept($cat,$pkg,@builds);
			} else {
				$self->accept($cat,$pkg);
			}
		};
	}
};
sub gen_methods($) {
	my ($self) = @_;
	die 'ref \$self="',ref $self,'"' unless $self->isa("Gentoo::Probe");
	no strict 'refs';
	for my $key (keys %{$self}){
		*$key = sub{
			my $self = shift;
			my $slot = \$self->{$key};
			my $res = $$slot;
			$$slot = shift if @_;
			$res;
		} unless defined &$key;
	};
};
1;
