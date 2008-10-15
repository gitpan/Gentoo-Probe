# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/perl/Gentoo-Probe/t/sandbox/var/db/pkg/app-portage/gentoolkit-0.2.0_pre8/gentoolkit-0.2.0_pre8.ebuild,v 1.1 2004/06/20 09:09:37 linguist Exp $

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/~karltk/projects/gentoolkit/"
SRC_URI="http://dev.gentoo.org/~genone/distfiles/${P}.tar.gz"
#SRC_URI="mirror://gentoo/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="x86 ppc sparc alpha mips hppa amd64 ia64 ppc64 s390"
#KEYWORDS="~x86 ~ppc ~sparc ~alpha ~mips ~hppa ~amd64 ~ia64 ~ppc64"

DEPEND=">=sys-apps/portage-2.0.50
	>=dev-lang/python-2.0
	>=dev-util/dialog-0.7
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.5-r1"

src_install() {
	make DESTDIR=${D} install-gentoolkit
}

pkg_postinst() {
	echo
	einfo "This version of ${PN} has a script to test the upcoming"
	einfo "portage GLSA integration (aka 'emerge security'). If you"
	einfo "want to try it out run"
	einfo "    glsa-check --help"
	einfo "and read the output carefully."
	echo
}
