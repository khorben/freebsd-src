#ifndef LDNS_INTERNAL_H
#define LDNS_INTERNAL_H

#include <ldns/dnssec_sign.h>

#ifdef __cplusplus
extern "C" {
#endif

/* dnssec_zone.c */
ldns_status
dnssec_zone_equip_zonemd(ldns_dnssec_zone *zone,
		ldns_rr_list *new_rrs, ldns_key_list *key_list, int signflags);

/* edns.c */
void
ldns_edns_set_code(ldns_edns_option *edns, ldns_edns_option_code code);
void
ldns_edns_set_data(ldns_edns_option *edns, void *data);
void
ldns_edns_set_size(ldns_edns_option *edns, size_t size);

/* net.c */
int
ldns_tcp_bgsend2(ldns_buffer *qbin,
		const struct sockaddr_storage *to, socklen_t tolen, 
		struct timeval timeout);
int
ldns_tcp_connect2(const struct sockaddr_storage *to, socklen_t tolen, 
		struct timeval timeout);
int
ldns_udp_bgsend2(ldns_buffer *qbin,
		const struct sockaddr_storage *to  , socklen_t tolen, 
		struct timeval timeout);
int
ldns_udp_connect2(const struct sockaddr_storage *to, struct timeval ATTR_UNUSED(timeout));

/* packet.c */
ldns_edns_option_list*
pkt_edns_data2edns_option_list(const ldns_rdf *edns_data);

/* rr.c */
ldns_status
_ldns_rr_new_frm_fp_l_internal(ldns_rr **newrr, FILE *fp,
		uint32_t *default_ttl, ldns_rdf **origin, ldns_rdf **prev,
		int *line_nr, bool *explicit_ttl);

/* util.c */
struct tm *
ldns_serial_arithmetics_gmtime_r(int32_t time, time_t now, struct tm *result);

#ifdef __cplusplus
}
#endif

#endif /* LDNS_INTERNAL_H */
