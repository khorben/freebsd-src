.PATH: ${.CURDIR:H}/common_source

BINDIR=	/usr/bin

PACKAGE=lp
PROG=	lpr
MAN=	lpr.1 printcap.5
BINOWN=	root
BINGRP=	daemon
BINMODE= 6555

CFLAGS+= -I${.CURDIR:H}/common_source

WARNS?=	2

LIBADD=	lpr

.include <bsd.prog.mk>
