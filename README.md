docker-squid-sslbump-rpi
======================
squid 5.1 ssl proxy with icap for docker on raspberry pi. Based on [justinschw/docker-squid-sslbump-rpi](https://github.com/justinschw/docker-squid-sslbump-rpi).

Baseimage
======================
raspbian/stretch

Docker buildx setup
======================
I'm building these images on my significantly more powerful linux desktop and for that I use `docker buildx`
in order to get that to function properly I found installing the latest [qemu](https://hub.docker.com/r/docker/binfmt/tags)
image enables the linux/arm64, linux/arm/v7 or linux/arm/v6 architectures needed for buildx. Docker buildx setup was taken from this [blog](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/)
```sh
docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
```

Usage
======================
```sh
git clone https://github.com/dbreedt/docker-squid-sslbump-rpi.git
cd docker-squid-sslbump-rpi
# building for Raspberry Pi 3 Model B Rev 1.2
# Note: this takes about an hour depending on how beefy your machine is
docker buildx build --platform linux/arm/v7 -t docker-squid-sslbump-rpi .
docker run -ti -p 3128:3128 docker-squid-sslbump-rpi
```

Note
======================
Make sure your proxy is safe.

To prevent unwanted use, firewalls or some squid-acls should be applied.

See: [entrypoint.sh](https://github.com/justinschw/docker-squid-sslbump-rpi/blob/master/entrypoint.sh)
