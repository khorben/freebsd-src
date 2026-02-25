PKGDIR=		${SRCTOP}/contrib/pkg

LIB=		picosat
NO_PIC=

CFLAGS+=	${PICFLAG}
CFLAGS+=	-DNGETRUSAGE
CFLAGS+=	-I${PKGDIR}/external/picosat
CFLAGS+=	-Wno-error=cast-align
CFLAGS+=	-Wno-error=missing-prototypes
CFLAGS+=	-Wno-error=shadow
CFLAGS+=	-Wno-error=unused-but-set-variable

# From contrib/pkg/external/picosat/Makefile.autosetup
SRCS=	\
	picosat.c \
	version.c

MK_INSTALLLIB=	no

.PATH:	${PKGDIR}/external/picosat

.include <bsd.lib.mk>
