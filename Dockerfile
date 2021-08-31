FROM raspbian/stretch

ENV SQUID_USER=squid
ENV SQUID_DIR /usr/local/squid
ENV SQUID_MV v5
ENV SQUID_VER 5.1
ENV ARCNAME squid-$SQUID_VER.tar.gz
ENV ARCFOLDER squid-$SQUID_VER
ENV SQUID_LINK http://www.squid-cache.org/Versions/$SQUID_MV/$ARCNAME

RUN apt-get update && \
    apt-get -qq -y install openssl libssl1.0-dev build-essential wget curl net-tools dnsutils tcpdump && \
    apt-get clean

# squid - fetch and build
RUN wget $SQUID_LINK && \
    tar xzvf $ARCNAME && \
    cd $ARCFOLDER && \
    ./configure --prefix=$SQUID_DIR --enable-ssl --with-openssl --enable-ssl-crtd --with-large-files --enable-auth --enable-icap-client && \
    make -j6 && \
    make install && \
    cd .. && \
    rm -rf ${ARCFOLDER}

RUN mkdir -p $SQUID_DIR/var/lib
RUN mkdir -p $SQUID_DIR/ssl
RUN $SQUID_DIR/libexec/security_file_certgen -c -s $SQUID_DIR/var/lib/ssl_db -M 4MB
RUN mkdir -p $SQUID_DIR/var/cache
RUN useradd $SQUID_USER -U -b $SQUID_DIR
RUN chown -R ${SQUID_USER}:${SQUID_USER} $SQUID_DIR

# set config
RUN echo "" && echo "Updating Squid Config..."
RUN echo "#====added config===" >> $SQUID_DIR/etc/squid.conf
RUN echo "cache_effective_user $SQUID_USER" >> $SQUID_DIR/etc/squid.conf
RUN echo "cache_effective_group $SQUID_USER" >> $SQUID_DIR/etc/squid.conf

# these two settings disable caching if you want caching add them back
# see FAQ: https://wiki.squid-cache.org/SquidFaq/ConfiguringSquid#Can_I_make_Squid_proxy_only.2C_without_caching_anything.3F
RUN echo "cache deny all" >> $SQUID_DIR/etc/squid.conf
RUN echo "cache_dir null /tmp" >> $SQUID_DIR/etc/squid.conf

RUN echo "always_direct allow all" >> $SQUID_DIR/etc/squid.conf
RUN echo "icap_service_failure_limit -1" >> $SQUID_DIR/etc/squid.conf
RUN echo "ssl_bump server-first all" >> $SQUID_DIR/etc/squid.conf
RUN echo "sslproxy_cert_error allow all" >> $SQUID_DIR/etc/squid.conf
RUN sed "/^http_port 3128$/d" -i $SQUID_DIR/etc/squid.conf
RUN sed "s/^http_access allow localnet$/http_access allow all/" -i $SQUID_DIR/etc/squid.conf
RUN echo "http_port 3128 ssl-bump generate-host-certificates=on cert=$SQUID_DIR/ssl/localCert.crt key=$SQUID_DIR/ssl/localCert.pem" >> $SQUID_DIR/etc/squid.conf
RUN echo "sslcrtd_program /usr/local/squid/libexec/security_file_certgen -s /usr/local/squid/var/lib/ssl_db -M 4MB" >> $SQUID_DIR/etc/squid.conf
RUN echo "sslcrtd_children 3 startup=1 idle=1" >> $SQUID_DIR/etc/squid.conf

# making a cert
RUN openssl req -new -newkey rsa:2048 -nodes -days 3650 -x509 -keyout $SQUID_DIR/ssl/localCert.pem -out $SQUID_DIR/ssl/localCert.crt -subj "/C=ZA/ST=JouMa/L=JouMaSeAnderDorp/O=Lol/OU=NetworkSecurity/CN=localCert"
RUN openssl x509 -in $SQUID_DIR/ssl/localCert.crt -outform DER -out $SQUID_DIR/ssl/localCert.der

EXPOSE 3128

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
