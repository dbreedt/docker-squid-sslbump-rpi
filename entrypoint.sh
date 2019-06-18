#!/bin/bash
# encoding: utf-8

SQUID_USER=squid
SQUID_DIR=/usr/local/squid

openssl req -new -newkey rsa:2048 -nodes -days 3650 -x509 -keyout $SQUID_DIR/myCA.pem -out $SQUID_DIR/myCA.crt \
 -subj "/C=JP/ST=Ikebukuro/L=Tokyo/O=Dollers/OU=Dollers Co.,Ltd./CN=squid.local"
openssl x509 -in $SQUID_DIR/myCA.crt -outform DER -out $SQUID_DIR/myCA.der
mkdir -p $SQUID_DIR/var/lib
$SQUID_DIR/libexec/ssl_crtd -c -s $SQUID_DIR/var/lib/ssl_db
mkdir -p $SQUID_DIR/var/cache
useradd $SQUID_USER -U -b $SQUID_DIR
chown -R ${SQUID_USER}:${SQUID_USER} $SQUID_DIR
echo "#====added config===" >> $SQUID_DIR/etc/squid.conf
echo "cache_effective_user $SQUID_USER" >> $SQUID_DIR/etc/squid.conf
echo "cache_effective_group $SQUID_USER" >> $SQUID_DIR/etc/squid.conf
echo "always_direct allow all" >> $SQUID_DIR/etc/squid.conf
echo "icap_service_failure_limit -1" >> $SQUID_DIR/etc/squid.conf
echo "ssl_bump server-first all" >> $SQUID_DIR/etc/squid.conf
echo "sslproxy_cert_error allow all" >> $SQUID_DIR/etc/squid.conf
echo "sslproxy_flags DONT_VERIFY_PEER" >> $SQUID_DIR/etc/squid.conf
sed "/^http_port 3128$/d" -i $SQUID_DIR/etc/squid.conf
sed "s/^http_access allow localnet$/http_access allow all/" -i $SQUID_DIR/etc/squid.conf
echo "http_port 3128 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=$SQUID_DIR/myCA.crt key=$SQUID_DIR/myCA.pem" >> $SQUID_DIR/etc/squid.conf
cat $SQUID_DIR/etc/squid.conf | grep added\ config -A1000 #fflush()
echo "#===added config==="
exec $SQUID_DIR/sbin/squid -f $SQUID_DIR/etc/squid.conf -NYCd 10
#$SQUID_DIR/sbin/squid -d 10 -f $SQUID_DIR/etc/squid.conf

#bash
