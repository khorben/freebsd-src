PKGDIR=		${SRCTOP}/contrib/pkg

LIB=		lua
NO_PIC=

CFLAGS+=	${PICFLAG}
CFLAGS+=	-DLUA_USE_POSIX
CFLAGS+=	-Wno-error=cast-align
CFLAGS+=	-Wno-error=cast-qual

# From contrib/pkg/external/liblua/Makefile.autosetup
SRCS=	\
	lapi.c \
	lcode.c \
	lctype.c \
	ldebug.c \
	ldo.c \
	ldump.c \
	lfunc.c \
	lgc.c \
	llex.c \
	lmem.c \
	lobject.c \
	lopcodes.c \
	lparser.c \
	lstate.c \
	lstring.c \
	ltable.c \
	ltm.c \
	lundump.c \
	lvm.c \
	lzio.c \
	lauxlib.c \
	lbaselib.c \
	lcorolib.c \
	ldblib.c \
	liolib.c \
	lmathlib.c \
	loslib.c \
	lstrlib.c \
	ltablib.c \
	lutf8lib.c \
	loadlib.c \
	linit.c

MK_INSTALLLIB=	no

.PATH:	${PKGDIR}/external/lua/src

.include <bsd.lib.mk>
