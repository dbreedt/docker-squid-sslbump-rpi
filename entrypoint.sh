#!/bin/bash
# encoding: utf-8

SQUID_USER=squid
SQUID_DIR=/usr/local/squid

if [ ! -f $SQUID_DIR/bluestar.pem ]; then
    openssl req -new -newkey rsa:2048 -nodes -days 3650 -x509 -keyout $SQUID_DIR/bluestar.pem -out $SQUID_DIR/bluestar.crt\
	    -subj "/C=US/ST=Texas/L=Austin/O=BlueStar/OU=NetworkSecurity/CN=bluestar"
    RUN openssl x509 -in $SQUID_DIR/bluestar.crt -outform DER -out $SQUID_DIR/bluestar.der
fi
    

exec $SQUID_DIR/sbin/squid -f $SQUID_DIR/etc/squid.conf -NYCd 10
