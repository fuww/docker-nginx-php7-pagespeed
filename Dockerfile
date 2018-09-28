FROM ubuntu:latest

RUN export BUILD_PACKAGES="curl wget unzip sudo build-essential zlib1g-dev libpcre3-dev uuid-dev gpg gpg-agent" \
  && export SUDO_FORCE_REMOVE=yes \
  && export DEBIAN_FRONTEND=noninteractive \
  && export HEADERS_MORE_VERSION=0.33 \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install ca-certificates $BUILD_PACKAGES \
  && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list \
  && wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install \
    exim4 \
    php7.2-fpm \
    php7.2-mysql \
    php7.2-sqlite3 \
    php7.2-cli \
    php7.2-curl \
    php7.2-gd \
    php7.2-intl \
    php7.2-imap \
    php7.2-xml \
    php7.2-mbstring \
    php-pear \
    php7.2-pspell \
    php7.2-tidy \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-recode \
    php-memcached \
    php-redis \
    newrelic-php5 \
    supervisor \
  && phpenmod -v mcrypt imap memcached redis \
  && sed -i \
        -e "s/;\?newrelic.enabled =.*/newrelic.enabled = \${NEW_RELIC_ENABLED}/" \
        -e "s/newrelic.license =.*/newrelic.license = \${NR_INSTALL_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NR_APP_NAME}/" \
        /etc/php/7.2/fpm/conf.d/20-newrelic.ini \
  && mkdir -p /run/php/ \
  && wget -qO- https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz | tar zxf - -C /tmp \
  && bash -c "bash <(curl -f -L -sS https://ngxpagespeed.com/install) --nginx-version latest -a --add-module=/tmp/headers-more-nginx-module-${HEADERS_MORE_VERSION} -y" \
  && apt-get remove --purge -y $BUILD_PACKAGES \
  && apt-get autoremove --purge -y \
  && rm -rf /var/lib/apt/lists/* /tmp/*

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

COPY .root /
