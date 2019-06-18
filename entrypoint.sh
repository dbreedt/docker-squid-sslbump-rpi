#!/bin/bash
# encoding: utf-8

SQUID_USER=squid
SQUID_DIR=/usr/local/squid

exec $SQUID_DIR/sbin/squid -f $SQUID_DIR/etc/squid.conf -NYCd 10
