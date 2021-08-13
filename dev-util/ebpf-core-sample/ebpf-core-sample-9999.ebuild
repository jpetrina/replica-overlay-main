# Copyright 2021 Sartura Ltd.
# Author: Jakov Petrina <jakov.petrina@sartura.hr>

EAPI=7

inherit git-r3 linux-info llvm toolchain-funcs

DESCRIPTION="Sample of eBPF CO-RE"
HOMEPAGE="https://github.com/sartura/ebpf-core-sample/tree/devel"

EGIT_REPO_URI="https://github.com/sartura/ebpf-core-sample.git"
EGIT_BRANCH="devel"

SLOT="0"
KEYWORDS="amd64 arm arm64 x86"

DEPEND="dev-libs/libbpf:=
	virtual/libelf"
RDEPEND="${DEPEND}"
BDEPEND="sys-devel/clang:=[llvm_targets_BPF(+)]
	dev-util/bpftool"

RESTRICT="test strip"

CONFIG_CHECK="~BPF ~BPF_EVENTS ~BPF_JIT ~BPF_SYSCALL ~HAVE_EBPF_JIT ~DEBUG_INFO_BTF"

llvm_pkg_setup() {
	# eclass version will die if no LLVM can be found which will break prefix
	# bootstrap
	:
}

src_prepare() {
	# FIXME: Calling this function from `pkg_setup` causes `git-r3_sub_checkout`
	#        to fail due to work directory being created with the wrong owner.
	linux-info_pkg_setup
}

src_compile() {
	emake \
		ARCH="$(tc-arch-kernel)" \
		all
}
