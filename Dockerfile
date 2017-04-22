FROM ubuntu:latest

# Update packages and install software
RUN apt-get update \
    && apt-get -y install vim libfuse2 unionfs-fuse unzip curl \
    && apt-get -y install apache2 php-bz2 php-curl php-gd php-imagick php-intl php-mbstring php-xml php-zip sqlite3 php-sqlite3 \
    && apt-get install -y sudo libapache2-mod-php

ENV PUID=1000\
    PGID=1000

RUN adduser --disabled-password --uid $PUID --gecos '' abc \
    && adduser abc sudo \
    && adduser abc www-data

RUN echo 'abc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY nextcloud.conf /etc/apache2/sites-available/

RUN a2ensite nextcloud \
    && a2enmod rewrite \
    && a2enmod headers \
    && a2enmod ssl \
    && chown -R abc /var/www

ENV APACHE_RUN_USER=abc\
    APACHE_RUN_GROUP=abc

RUN echo 'export APACHE_RUN_USER=abc\nexport APACHE_RUN_GROUP=abc' >> /etc/apache2/envvars

USER abc

COPY nextcloud.sh /tmp

RUN cd /tmp && curl -LO https://download.nextcloud.com/server/releases/nextcloud-11.0.2.zip \
    && unzip nextcloud*zip && mv nextcloud /var/www/ \
    && sudo bash /tmp/nextcloud.sh \
    && rm nextcloud*zip

VOLUME /var/www/nextcloud/data/
VOLUME /var/www/nextcloud/config

# Expose port and run
EXPOSE 80 443
CMD ["sudo", "/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
