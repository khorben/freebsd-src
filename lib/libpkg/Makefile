PKGDIR=		${SRCTOP}/contrib/pkg

SUBDIR= \
	libblake2 \
	libcurl \
	liblua \
	libpicosat \
	librepo-binary

PACKAGE=	pkg
PRIVATELIB=	yes
LIB=		pkg

LIBADD=		archive
LIBADD+=	elf
LIBADD+=	sqlite3
LIBADD+=	ssl crypto
LIBADD+=	util

CFLAGS+=	-DHAVE_CONFIG_H
CFLAGS+=	-DPREFIX=\"/usr/local\"
CFLAGS+=	-I${SRCTOP}/lib/liblua
CFLAGS+=	-I${SRCTOP}/lib/libpkg
CFLAGS+=	-I${PKGDIR}
CFLAGS+=	-I${PKGDIR}/compat
CFLAGS+=	-I${PKGDIR}/external/curl/include
CFLAGS+=	-I${PKGDIR}/external/include
CFLAGS+=	-I${PKGDIR}/external/picosat
CFLAGS+=	-I${PKGDIR}/external/yxml
CFLAGS+=	-I${PKGDIR}/libpkg
CFLAGS+=	-I${SRCTOP}/contrib/libder/libder
CFLAGS+=	-I${SRCTOP}/contrib/libucl/include
CFLAGS+=	-I${SRCTOP}/contrib/libucl/uthash
CFLAGS+=	-I${SRCTOP}/contrib/lua/src
CFLAGS+=	-I${SRCTOP}/contrib/sqlite3
CFLAGS+=	-I${SRCTOP}/crypto/libecc/include
CFLAGS+=	-I${SRCTOP}/sys/contrib/libb2
CFLAGS+=	-Wno-error=cast-align
CFLAGS+=	-Wno-error=cast-qual
CFLAGS+=	-Wno-error=deprecated-declarations
CFLAGS+=	-Wno-error=incompatible-pointer-types-discards-qualifiers
CFLAGS+=	-Wno-error=int-conversion
CFLAGS+=	-Wno-error=missing-field-initializers
CFLAGS+=	-Wno-error=missing-prototypes
CFLAGS+=	-Wno-error=missing-variable-declarations
CFLAGS+=	-Wno-error=shadow
CFLAGS+=	-Wno-error=sign-compare
CFLAGS+=	-Wno-error=strict-prototypes
CFLAGS+=	-Wno-error=switch
CFLAGS.binfmt_macho.c+=	-DHAVE_SYS_ENDIAN_H=1
CFLAGS.pkg_elf.c+=	-DHAVE_SYS_ENDIAN_H=1
CFLAGS.fetch_libcurl.c+=-Wno-error=attribute-warning
CFLAGS.ssh.c+=	-Wno-error=implicit-function-declaration

LDFLAGS+=	libblake2/libblake2.a
LDFLAGS+=	libcurl/libcurl.a
LDFLAGS+=	liblua/liblua.a
LDFLAGS+=	libpicosat/libpicosat.a
LDFLAGS+=	librepo-binary/librepo-binary.a

SRCS=	backup_lib.c \
	merge3.c \
	pkg_audit.c \
	pkg_deps.c \
	pkg_repo_meta.c \
	pkg.c \
	pkg_key.c \
	pkgsign.c \
	pkgsign_ecc.c \
	pkgsign_ossl.c \
	clean_cache.c \
	metalog.c \
	pkg_checksum.c \
	pkg_manifest.c \
	pkg_repo_update.c \
	pkgdb_iterator.c \
	lua.c \
	lua_scripts.c \
	scripts.c \
	diff.c \
	packing.c \
	pkg_config.c \
	pkg_event.c \
	pkg_object.c \
	pkg_osvf.c \
	pkg_repo.c \
	pkgdb_query.c \
	sha256.c dns_utils.c \
	pkg_add.c \
	pkg_create.c \
	pkg_jobs_conflicts.c pkg_ports.c \
	pkg_solve.c \
	pkgdb.c \
	pkg_abi.c \
	pkg_elf.c \
	pkg_abi_macho.c \
	binfmt_macho.c \
	ssh.c \
	pkgbase.c \
	pkg_arch.c \
	pkg_cudf.c \
	pkg_cpe.c \
	pkg_jobs_universe.c  pkg_printf.c \
	pkg_status.c \
	plugins.c \
	utils.c fetch.c \
	pkg_sandbox.c \
	pkg_attributes.c \
	pkg_delete.c \
	pkg_jobs.c \
	pkg_jobs_schedule.c \
	pkg_repo_create.c \
	pkg_version.c \
	rcscripts.c \
	flags.c \
	fetch_ssh.c \
	fetch_libcurl.c \
	fetch_file.c \
	triggers.c \
	pkghash.c \
	yuarel.c \
	json.c

.PATH:	${PKGDIR}/libpkg

.include <bsd.lib.mk>
