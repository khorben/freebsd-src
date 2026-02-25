PKGDIR=		${SRCTOP}/contrib/pkg

LIB=		blake2
NO_PIC=

CFLAGS+=	${PICFLAG}
CFLAGS+=	-I${PKGDIR}/compat
CFLAGS+=	-O3

# From contrib/pkg/external/blake2/Makefile.autosetup
SRCS=	\
	blake2b-ref.c \
	blake2s-ref.c

MK_INSTALLLIB=	no

.PATH:	${PKGDIR}/external/blake2

.include <bsd.lib.mk>
