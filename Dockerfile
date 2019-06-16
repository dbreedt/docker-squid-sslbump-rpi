FROM raspbian/stretch
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

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

EXPOSE 3128

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
