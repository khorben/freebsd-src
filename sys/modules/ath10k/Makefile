DEVATH10KDIR=	${SRCTOP}/sys/contrib/dev/athk/ath10k

.PATH: ${DEVATH10KDIR}

WITH_CONFIG_FWLOG=	1

KMOD=	if_ath10k

SRCS+=	core.c debug.c mac.c ce.c hw.c bmi.c
SRCS+=	htc.c htt.c htt_rx.c htt_tx.c
SRCS+=	txrx.c wmi.c wmi-tlv.c
SRCS+=	p2p.c swap.c

SRCS+=	pci.c

# Other
SRCS+=	${LINUXKPI_GENSRCS}
SRCS+=	opt_wlan.h opt_inet6.h opt_inet.h opt_acpi.h

.if defined(WITH_CONFIG_FWLOG) && ${WITH_CONFIG_FWLOG} > 0
SRCS+=	fwlog.c
CFLAGS+=	-DCONFIG_FWLOG=${WITH_CONFIG_FWLOG}
.endif

CFLAGS+=	-DKBUILD_MODNAME='"ath10k"'

CFLAGS+=	-I${DEVATH10KDIR}
CFLAGS+=	-I${DEVATH10KDIR}/..
CFLAGS+=	${LINUXKPI_INCLUDES}
# Helpful after fresh imports.
#CFLAGS+=	-ferror-limit=0

CFLAGS+=	-DCONFIG_ATH10K_DEBUG

#CFLAGS+=	-DCONFIG_ATH10K_AHB
#CFLAGS+=	-DCONFIG_ATH10K_DEBUGFS
#CFLAGS+=	-DCONFIG_ATH10K_DFS_CERTIFIED
#CFLAGS+=	-DCONFIG_ATH10K_SPECTRAL
#CFLAGS+=	-DCONFIG_ATH10K_TRACING
#CFLAGS+=	-DCONFIG_DEV_COREDUMP
#CFLAGS+=	-DCONFIG_MAC80211_DEBUGFS
#CFLAGS+=	-DCONFIG_MAC80211_MESH
#CFLAGS+=	-DCONFIG_NL80211_TESTMODE
#CFLAGS+=	-DCONFIG_PM
#CFLAGS+=	-DCONFIG_PM_SLEEP
#CFLAGS+=	-DCONFIG_THERMAL

.include <bsd.kmod.mk>
