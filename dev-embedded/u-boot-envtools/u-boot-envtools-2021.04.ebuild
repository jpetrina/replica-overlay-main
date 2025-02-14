# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs

MY_P="u-boot-${PV/_/-}"
DESCRIPTION="utilities for working with Das U-Boot environment"
HOMEPAGE="https://www.denx.de/wiki/U-Boot/WebHome"
SRC_URI="ftp://ftp.denx.de/pub/u-boot/${MY_P}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 arm ~arm64 ~ppc64 ~x86"
IUSE=""

BDEPEND="
	sys-devel/bison
	sys-devel/flex
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	default
	sed -i 's:\bpkg-config\b:${PKG_CONFIG}:g' \
		scripts/kconfig/Makefile \
		tools/Makefile || die

	mkdir -p include/config
	touch include/config.h
	touch include/config/auto.conf
	mkdir -p include/generated
	touch include/generated/autoconf.h
}

src_configure() {
	tc-export AR CC PKG_CONFIG
}

src_compile() {
	# Unset a few KBUILD variables. Bug #540476
	unset KBUILD_OUTPUT KBUILD_SRC

	emake \
		V=1 \
		AR="${AR}" \
		CC="${CC}" \
		HOSTCC="${HOSTCC}" \
		HOSTCFLAGS="${CFLAGS} ${CPPFLAGS}"' $(HOSTCPPFLAGS)' \
		HOSTLDFLAGS="${LDFLAGS}" \
		tools-only_defconfig

	emake \
		V=1 \
		NO_SDL=1 \
		HOSTSTRIP=: \
		STRIP=: \
		AR="${AR}" \
		CC="${CC}" \
		HOSTCC="${HOSTCC}" \
		HOSTCFLAGS="${CFLAGS} ${CPPFLAGS}"' $(HOSTCPPFLAGS)' \
		HOSTLDFLAGS="${LDFLAGS}" \
		CONFIG_ENV_OVERWRITE=y \
		envtools
}

src_test() { :; }

src_install() {
	cd tools || die
	dobin env/fw_printenv
	dosym fw_printenv /usr/bin/fw_setenv
	insinto /etc
	doins env/fw_env.config
}