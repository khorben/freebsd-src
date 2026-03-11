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

.include <bsd.lib.mk>

.PATH:	${PKGDIR}/external/blake2
