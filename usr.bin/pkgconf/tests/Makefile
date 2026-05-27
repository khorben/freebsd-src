.include <src.opts.mk>

PACKAGE=	tests

PKGCONFDIR=	${SRCTOP}/contrib/pkgconf

# from contrib/pkgconf/meson.build:281
PROGS+=		test-runner

SRCS.test-runner=core.c						\
	getopt_long.c						\
	renderer-msvc.c						\
	test-runner.c

LIBADD.test-runner=	pkgconf

# from contrib/pkgconf/meson.build:292
API_TESTS=audit							\
	buffer							\
	bytecode						\
	client							\
	dependency						\
	fileio							\
	fragment						\
	license							\
	path-utils						\
	personality						\
	queue							\
	tuple							\
	variable						\
	version

# from contrib/pkgconf/meson.build:309
.for test in ${API_TESTS}
PROGS+=			test-api-${test}

SRCS.test-api-${test}=	test-${test}.c

LIBADD.test-api-${test}=pkgconf
.endfor

# from contrib/pkgconf/t
TEST_DATA=t/basic						\
	  t/bomtool						\
	  t/cli							\
	  t/link-abi						\
	  t/ordering						\
	  t/parser						\
	  t/personality						\
	  t/sbom						\
	  t/solver						\
	  t/spdxtool						\
	  t/symlink						\
	  t/sysroot						\
	  t/tuple						\
	  tests/lib1						\
	  tests/lib1/child-prefix/pkgconfig			\
	  tests/lib2						\
	  tests/lib3						\
	  tests/lib-relocatable/lib/pkgconfig			\
	  tests/lib-sbom					\
	  tests/lib-sbom-files					\
	  tests/personality-data
.for t in ${TEST_DATA}
afterinstall: install-pkgconf-test-data-${t}

install-pkgconf-test-data-${t}: .PHONY
	${INSTALL} -d ${TAG_ARGS} -m ${DIRMODE}			\
		${DESTDIR}${TESTSDIR}/${t}
	find ${PKGCONFDIR}/${t} -depth 1 -type f		\
		-exec ${INSTALL} ${TAG_ARGS} -m ${NOBINMODE}	\
		{} ${DESTDIR}${TESTSDIR}/${t}/ \;
.endfor

# from contrib/pkgconf/meson.build:320
PROGS+=			test-api-serialize
SRCS.test-api-serialize=test-serialize.c			\
	spdxtool/core.c						\
	spdxtool/software.c					\
	spdxtool/serialize.c					\
	spdxtool/simplelicensing.c				\
	spdxtool/util.c
LIBADD.test-api-serialize=pkgconf

BINDIR=		${TESTSDIR}

SYMLINKS=	/usr/bin/bomtool ${TESTSDIR}/bomtool
SYMLINKS+=	/usr/bin/pkgconf ${TESTSDIR}/pkgconf
SYMLINKS+=	/usr/bin/spdxtool ${TESTSDIR}/spdxtool

WARNS?=		3

CFLAGS+=	-I${SRCTOP}/lib/libpkgconf
CFLAGS+=	-I${PKGCONFDIR}
CFLAGS+=	-I${PKGCONFDIR}/cli/spdxtool

.PATH:		${PKGCONFDIR}/tests/api
.PATH:		${PKGCONFDIR}/tests
.PATH:		${PKGCONFDIR}/cli

TAP_TESTS_SH=	pkgconf_tests

.include <bsd.test.mk>
