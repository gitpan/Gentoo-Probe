# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/wireless-tools/wireless-tools-27_pre17.ebuild,v 1.2 2004/06/15 03:04:20 agriffis Exp $

MY_P=wireless_tools.${PV/_/\.}
S=${WORKDIR}/${MY_P/.pre17/}
DESCRIPTION="A collection of tools to configure wireless lan cards."
SRC_URI="http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/${MY_P}.tar.gz"
HOMEPAGE="http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html"
KEYWORDS="~x86"
SLOT="0"
LICENSE="GPL-2"
DEPEND="virtual/glibc"
RDEPEND="${DEPEND}"
IUSE="nls"

src_unpack() {
	unpack ${A}
	cd ${S}

	check_KV

	mv Makefile ${T}
	sed -e "s:# KERNEL_SRC:KERNEL_SRC:" \
		-e "s:^CFLAGS=:CFLAGS=${CFLAGS} :" \
		${T}/Makefile > Makefile
}

src_compile() {
	emake WARN="" || die
}

src_install () {
	dosbin iwconfig iwevent iwgetid iwpriv iwlist iwspy ifrename

	dolib libiw.so.27
	insinto /usr/include/
	doins iwlib.h
	dosym /usr/lib/libiw.so.27 /usr/lib/libiw.so

	doman {iwconfig,iwlist,iwpriv,iwspy,iwgetid,iwevent,ifrename}.8 \
		wireless.7 iftab.5

	if use nls; then
		insinto /usr/share/man/fr/man8
		doins {iwconfig,iwlist,iwpriv,iwspy,iwgetid,iwevent}.8
	fi

	dodoc CHANGELOG.h COPYING INSTALL HOTPLUG.txt PCMCIA.txt README
}