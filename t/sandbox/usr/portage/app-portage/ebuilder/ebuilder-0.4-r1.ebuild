# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/ebuilder/ebuilder-0.4-r1.ebuild,v 1.3 2004/04/07 18:56:13 genone Exp $

S="${WORKDIR}/${P}"
DESCRIPTION="Package Builder for Gentoo Linux"
SRC_URI="http://dev.gentoo.org/~genone/distfiles/${P}.tar.gz"
HOMEPAGE="http://www.disinformation.ca/gentoo"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="x86 ppc sparc"

DEPEND="net-misc/wget"
RDEPEND="$DEPEND"

src_compile() {
	echo "Nothing to compile for ${P}."
}

src_install () {
	dodir /usr/share/ebuilder
	dodir /usr/share/ebuilder/templates

	insinto /usr/share/ebuilder/templates
	doins templates/beginner.ebuild
	doins templates/expert.ebuild

	dosbin ebuilder
	doman man/ebuilder.1

	# Install documentation.
	dodoc AUTHORS ChangeLog COPYING NEWS README TODO
}
