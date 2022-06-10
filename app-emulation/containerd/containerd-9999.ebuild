# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Flatcar: Based on containerd-1.0.1.ebuild from commit
# 681cbfee60f214c2cfb719ba6f6cdf59cbab03a1 in Gentoo repo (see
# https://gitweb.gentoo.org/repo/gentoo.git/plain/app-emulation/containerd/containerd-1.0.1.ebuild?id=681cbfee60f214c2cfb719ba6f6cdf59cbab03a1)

EAPI=6

GITHUB_URI="github.com/containerd/containerd"
COREOS_GO_PACKAGE="${GITHUB_URI}"
COREOS_GO_VERSION="go1.15"

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI="https://${GITHUB_URI}.git"
	inherit git-r3
else
	MY_PV="${PV/_rc/-rc.}"
	EGIT_COMMIT="v${MY_PV}"
	CONTAINERD_COMMIT="380151a8cd5a993e485ad4f4fd93c881b65cc13f"
	SRC_URI="https://${GITHUB_URI}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm64"
	inherit vcs-snapshot
fi

inherit coreos-go systemd

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+btrfs hardened"

DEPEND="btrfs? ( sys-fs/btrfs-progs )"
RDEPEND="~app-emulation/docker-runc-1.0.0_rc92
	sys-libs/libseccomp"

S=${WORKDIR}/${P}/src/${COREOS_GO_PACKAGE}

RESTRICT="test"

src_unpack() {
	mkdir -p "${S}"
	tar --strip-components=1 -C "${S}" -xf "${DISTDIR}/${A}"
}

src_prepare() {
	coreos-go_src_prepare
	if [[ ${PV} != *9999* ]]; then
		sed -i -e "s/git describe --match.*$/echo ${PV})/"\
			-e "s/git rev-parse HEAD.*$/echo $CONTAINERD_COMMIT)/"\
			-e "s/-s -w//" \
			Makefile || die
	fi
}

src_compile() {
	local options=( $(usex btrfs "" "no_btrfs") )
	export GOPATH="${WORKDIR}/${P}" # ${PWD}/vendor
	LDFLAGS=$(usex hardened '-extldflags -fno-PIC' '') emake BUILDTAGS="${options[*]}"
}

src_install() {
	dobin bin/containerd{-shim,-shim-runc-v*,-stress,} bin/ctr
	systemd_newunit "${FILESDIR}/${PN}-1.0.0.service" "${PN}.service"
	insinto /usr/share/containerd
	doins "${FILESDIR}/config.toml"
}
