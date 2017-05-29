# welliton/ga4gh-server:0.3.6

FROM debian:jessie

MAINTAINER Welliton Souza <well309@gmail.com>

RUN apt-get update --fix-missing && \
    apt-get upgrade --yes && \
    apt-get install --yes wget curl libcurl4-openssl-dev \
        build-essential python python-dev python-distribute \
        python-pip zlib1g-dev apache2 libapache2-mod-wsgi libxslt1-dev \
        libffi-dev libssl-dev && \
    pip install --upgrade pip setuptools && \
    pip install ga4gh-server==0.3.6 && \
    a2enmod wsgi && \
    mkdir /var/cache/apache2/python-egg-cache && \
    chown www-data:www-data /var/cache/apache2/python-egg-cache/ && \
    mkdir -p /srv/ga4gh /data && \
    ga4gh_repo init /data/registry.db

COPY 001-ga4gh.conf /etc/apache2/sites-available/001-ga4gh.conf
COPY application.wsgi /srv/ga4gh/application.wsgi
COPY config.py /srv/ga4gh/config.py
COPY peers.txt /srv/ga4gh/peers.txt

WORKDIR /etc/apache2/sites-enabled
RUN a2dissite 000-default && \
    a2ensite 001-ga4gh

WORKDIR /srv/ga4gh

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
