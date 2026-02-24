PKGDIR=		${SRCTOP}/contrib/pkg

LIB=		repo-binary
NO_PIC=

CFLAGS+=	${PICFLAG}
CFLAGS+=	-I${SRCTOP}/lib/libpkg
CFLAGS+=	-I${PKGDIR}/libpkg
CFLAGS+=	-I${PKGDIR}/compat
CFLAGS+=	-I${SRCTOP}/contrib/libucl/include
CFLAGS+=	-I${SRCTOP}/contrib/libucl/uthash
CFLAGS+=	-I${SRCTOP}/contrib/sqlite3
CFLAGS+=	-I${PKGDIR}/external/include
CFLAGS+=	-Wno-error=cast-qual
CFLAGS+=	-Wno-error=missing-prototypes
CFLAGS+=	-Wno-error=strict-prototypes

SRCS=	binary.c \
	common.c \
	fetch.c \
	init.c \
	query.c \
	update.c

MK_INSTALLLIB=	no

.PATH:	${PKGDIR}/libpkg/repo/binary

.include <bsd.lib.mk>
