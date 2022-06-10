# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Flatcar: Based on docker-proxy-0.8.0_p20180626.ebuild from commit
# 3c4b080c3be104d392547da48767776e343f23c0 in Gentoo repo (see
# https://gitweb.gentoo.org/repo/gentoo.git/plain/app-emulation/docker-proxy/docker-proxy-0.8.0_p20180626.ebuild?id=3c4b080c3be104d392547da48767776e343f23c0)

EAPI=6
EGO_PN="github.com/docker/libnetwork"

COREOS_GO_PACKAGE="${EGO_PN}"
COREOS_GO_VERSION="go1.15"

if [[ ${PV} == *9999 ]]; then
	KEYWORDS="~amd64 ~arm64"
	inherit golang-vcs
else
	EGIT_COMMIT="3ac297bc7fd0afec9051bbb47024c9bc1d75bf5b"
	SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm64"
	inherit golang-vcs-snapshot
fi

inherit coreos-go

DESCRIPTION="Docker container networking"
HOMEPAGE="https://github.com/docker/libnetwork"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

S=${WORKDIR}/${P}/src/${EGO_PN}

RDEPEND="!<app-emulation/docker-1.13.0_rc1"

RESTRICT="test" # needs dockerd

src_compile() {
	go_build "${COREOS_GO_PACKAGE}/cmd/proxy"
}

src_install() {
	dodoc ROADMAP.md README.md CHANGELOG.md
	newbin "${GOBIN}"/proxy docker-proxy
}
