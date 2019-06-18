FROM raspbian/stretch
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

ENV SQUID_USER=squid
ENV SQUID_DIR /usr/local/squid

RUN apt-get update && \
    apt-get -qq -y install openssl libssl1.0-dev build-essential wget curl net-tools dnsutils tcpdump && \
    apt-get clean

# squid 3.5.27
RUN wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.27.tar.gz && \
    tar xzvf squid-3.5.27.tar.gz && \
    cd squid-3.5.27 && \
    ./configure --prefix=$SQUID_DIR --enable-ssl --with-openssl --enable-ssl-crtd --with-large-files --enable-auth --enable-icap-client && \
    make -j4 && \
    make install

RUN mkdir -p $SQUID_DIR/var/lib
RUN $SQUID_DIR/libexec/ssl_crtd -c -s $SQUID_DIR/var/lib/ssl_db
RUN mkdir -p $SQUID_DIR/var/cache
RUN useradd $SQUID_USER -U -b $SQUID_DIR
RUN chown -R ${SQUID_USER}:${SQUID_USER} $SQUID_DIR
RUN echo "#====added config===" >> $SQUID_DIR/etc/squid.conf
RUN echo "cache_effective_user $SQUID_USER" >> $SQUID_DIR/etc/squid.conf
RUN echo "cache_effective_group $SQUID_USER" >> $SQUID_DIR/etc/squid.conf
RUN echo "always_direct allow all" >> $SQUID_DIR/etc/squid.conf
RUN echo "icap_service_failure_limit -1" >> $SQUID_DIR/etc/squid.conf
RUN echo "ssl_bump server-first all" >> $SQUID_DIR/etc/squid.conf
RUN echo "sslproxy_cert_error allow all" >> $SQUID_DIR/etc/squid.conf
RUN echo "sslproxy_flags DONT_VERIFY_PEER" >> $SQUID_DIR/etc/squid.conf
RUN sed "/^http_port 3128$/d" -i $SQUID_DIR/etc/squid.conf
RUN sed "s/^http_access allow localnet$/http_access allow all/" -i $SQUID_DIR/etc/squid.conf
RUN echo "http_port 3128 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=$SQUID_DIR/bluestar.crt key=$SQUID_DIR/bluestar.pem" >> $SQUID_DIR/etc/squid.conf
RUN cat $SQUID_DIR/etc/squid.conf | grep added\ config -A1000 #fflush()


EXPOSE 3128

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
