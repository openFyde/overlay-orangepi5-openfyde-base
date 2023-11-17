# Copyright (c) 2020 The Fyde Innovations. All rights reserved.
# Distributed under the license specified in the root directory of this project.

EAPI="5"

inherit appid
DESCRIPTION="Creates an app id for this build and update the lsb-release file"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
      doappid "{9F6B2C94-9F8C-4206-9D63-7B16E6965143}" "CHROMEBOX"
}
