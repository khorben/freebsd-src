.include <src.opts.mk>

PACKAGE=pkg

PROG=	pkg
MAN=	pkg.7
SRCS=	add.c \
	alias.c \
	annotate.c \
	audit.c \
	autoremove.c \
	check.c \
	clean.c \
	config.c \
	create.c \
	delete.c \
	event.c \
	fetch.c \
	globals.c \
	info.c \
	install.c \
	key.c \
	lock.c \
	main.c \
	plugins.c \
	query.c \
	register.c \
	repo.c \
	repositories.c \
	rquery.c \
	search.c \
	set.c \
	shell.c \
	shlib.c \
	ssh.c \
	stats.c \
	triggers.c \
	unregister.c \
	update.c \
	updating.c \
	upgrade.c \
	utils.c \
	version.c \
	which.c

LIBADD=	jail pkg ucl util

PKGDIR=	${SRCTOP}/contrib/pkg

CFLAGS+=-DHAVE_CONFIG_H
CFLAGS+=-DGITHASH=\"\"
CFLAGS+=-DPKG_IN_BASE
CFLAGS+=-Wno-error=cast-qual
CFLAGS+=-Wno-error=format
CFLAGS+=-Wno-error=gnu-pointer-arith
CFLAGS+=-Wno-error=incompatible-pointer-types-discards-qualifiers
CFLAGS+=-Wno-error=missing-prototypes
CFLAGS+=-Wno-error=missing-variable-declarations
CFLAGS+=-Wno-error=shadow
CFLAGS+=-Wno-error=sign-compare

CFLAGS+=-I${SRCTOP}/contrib/libucl/include
CFLAGS+=-I${SRCTOP}/lib/libpkg
CFLAGS+=-I${PKGDIR}/compat
CFLAGS+=-I${PKGDIR}/libpkg

.PATH:	${PKGDIR}/src

.include <bsd.prog.mk>
