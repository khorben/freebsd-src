.PATH: ${SRCTOP}/sys/dev/usb/net

KMOD=	if_ure
SRCS+=	if_ure.c usbdevs.h
SRCS+=	bus_if.h device_if.h miibus_if.h usb_if.h \
	opt_bus.h opt_inet.h opt_inet6.h opt_usb.h opt_platform.h

.include <bsd.kmod.mk>
