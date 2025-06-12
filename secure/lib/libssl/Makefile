.include <src.opts.mk>

LIB=		ssl
SHLIB_MAJOR=	35
VERSION_MAP=	${.CURDIR}/Version.map
PACKAGE=	openssl-lib

NO_LINT=

PCFILES=	libssl.pc openssl.pc

.include "../libcrypto/Makefile.inc"

SRCS=	bio_ssl.c d1_lib.c d1_msg.c d1_srtp.c methods.c pqueue.c
SRCS+=	s3_enc.c s3_lib.c s3_msg.c ssl_asn1.c ssl_cert.c ssl_ciph.c
SRCS+=	ssl_conf.c ssl_err_legacy.c ssl_init.c ssl_lib.c ssl_mcnf.c
SRCS+=	ssl_rsa.c ssl_rsa_legacy.c ssl_sess.c ssl_stat.c ssl_txt.c ssl_utst.c
SRCS+=	t1_enc.c t1_lib.c t1_trce.c tls_depr.c tls_srp.c tls13_enc.c

# crypto
SRCS+=	packet.c quic_vlint.c time.c

# hashtable
SRCS+=	hashtable.c hashfunc.c

# quic
SRCS+=	quic_method.c quic_impl.c quic_wire.c quic_ackm.c quic_statm.c
SRCS+=	cc_newreno.c quic_demux.c quic_record_rx.c
SRCS+=	quic_record_tx.c quic_record_util.c quic_record_shared.c quic_wire_pkt.c
SRCS+=	quic_rx_depack.c
SRCS+=	quic_fc.c uint_set.c
SRCS+=	quic_cfq.c quic_txpim.c quic_fifd.c quic_txp.c
SRCS+=	quic_stream_map.c
SRCS+=	quic_sf_list.c quic_rstream.c quic_sstream.c
SRCS+=	quic_reactor.c
SRCS+=	quic_reactor_wait_ctx.c
SRCS+=	quic_channel.c quic_port.c quic_engine.c
SRCS+=	quic_tserver.c
SRCS+=	quic_thread_assist.c
SRCS+=	quic_trace.c
SRCS+=	quic_srtm.c quic_srt_gen.c
SRCS+=	quic_lcidm.c quic_rcidm.c
SRCS+=	quic_tls.c quic_tls_api.c
SRCS+=	quic_types.c
SRCS+=	qlog_event_helpers.c
SRCS+=	json_enc.c qlog.c
SRCS+=	getenv.c ctype.c
SRCS+=	quic_obj.c

# record
SRCS+=	rec_layer_d1.c rec_layer_s3.c

# record/methods
SRCS+=	tls_common.c ssl3_meth.c tls1_meth.c tls13_meth.c tlsany_meth.c
SRCS+=	dtls_meth.c tls_multib.c

# rio
SRCS+=	poll_immediate.c rio_notifier.c poll_builder.c

# siphash
SRCS+=	siphash.c

# statem
SRCS+=	extensions.c extensions_clnt.c extensions_cust.c extensions_srvr.c
SRCS+=	statem.c statem_clnt.c statem_dtls.c statem_lib.c statem_srvr.c

# thread
SRCS+=	api.c internal.c arch.c
SRCS+=	arch/thread_win.c arch/thread_posix.c arch/thread_none.c

.if ${MK_OPENSSL_KTLS} == "no"
CFLAGS+=-DOPENSSL_NO_KTLS
.endif

LIBADD=	crypto

CFLAGS+=	-I${LCRYPTO_SRC}/ssl
CFLAGS+=	-I${.OBJDIR:H}/libcrypto

.include <bsd.lib.mk>

PICFLAG+=	-DOPENSSL_PIC

.PATH:	${LCRYPTO_SRC}/crypto \
	${LCRYPTO_SRC}/crypto/hashtable \
	${LCRYPTO_SRC}/crypto/siphash \
	${LCRYPTO_SRC}/crypto/thread \
	${LCRYPTO_SRC}/ssl \
	${LCRYPTO_SRC}/ssl/quic \
	${LCRYPTO_SRC}/ssl/record \
	${LCRYPTO_SRC}/ssl/record/methods \
	${LCRYPTO_SRC}/ssl/rio \
	${LCRYPTO_SRC}/ssl/statem
