#
# SPDX-License-Idendifier: BSD-2-Clause
#
# Copyright (c) 2025 FreeBSD Foundation
#
# This sofware was developed by Cy Schubert <cy@FreeBSD.org>
# under sponsorship from the FreeBSD Foundation.
#

.PATH:	${KRB5_DIR}/lib/gssapi/spnego

SRCS+=	negoex_ctx.c \
	negoex_util.c \
	spnego_mech.c
