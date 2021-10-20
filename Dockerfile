FROM alpine:3.13

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		bash \
		re2c \
		php7-dev \
		php7-pear \
		pcre-dev \
		pcre2-dev \
		zlib-dev \
		libtool \
		automake

# persistent / runtime deps
RUN apk add --no-cache \
		ca-certificates \
		curl \
		tar \
		xz \
		vim \
		git \
# https://github.com/docker-library/php/issues/494
		openssl

# ensure www-data user exists
RUN set -eux; \
	addgroup -g 1000 -S www; \
	adduser -u 1000 -D -S -G www www

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /wwwroot ]; \
	mkdir -p /wwwroot; \
	chown www:www /wwwroot; \
	chmod 777 /wwwroot

ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

ENV PHP_VERSION 7.4.24
ENV PHP_URL="https://www.php.net/distributions/php-7.4.24.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.24.tar.xz.asc"
ENV PHP_SHA256="ff7658ee2f6d8af05b48c21146af5f502e121def4e76e862df5ec9fa06e98734"

ENV SWOOLE_VERSION=${SWOOLE_VERSION:-"4.5.2"}

RUN set -eux; \
	\
	apk add --no-cache --virtual .fetch-deps gnupg; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		gpgconf --kill all; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	apk del --no-network .fetch-deps

COPY docker-php-source /usr/local/bin/
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		argon2-dev \
		coreutils \
		curl-dev \
		libedit-dev \
		libsodium-dev \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		libpng-dev \
		php7-gd \
		oniguruma-dev \
		openssl-dev \
		sqlite-dev \
	; \
	\
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--enable-bcmath \
		--enable-gd \
		--with-mhash \
		--with-pdo_mysql \
		--enable-sockets \
		--enable-json \
		--enable-sysvshm \
		--enable-sysvmsg \
		--enable-sysvsem \
		--enable-pcntl \
		--enable-opcache \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		--with-pear \
		--with-xmlrpc \
		--with-xsl \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear") and will be removed in PHP 8+; see also https://github.com/docker-library/php/issues/846#issuecomment-505638494
		--with-pear \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
        \
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	rm -rf /usr/local/src; \ 
        \
# smoke test
	php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

RUN set -eux && \
        apk add imagemagick imagemagick-dev libstdc++ bash pcre-dev pcre2-dev libaio-dev libmemcached libmemcached-dev && \ 
        pecl install redis && \
        pecl install imagick-3.4.4 && \
	pecl install protobuf && \
	pecl install memcached && \
	pecl install xlswriter && \
	docker-php-ext-enable sodium && \
        docker-php-ext-enable redis && \
        docker-php-ext-enable imagick && \
        docker-php-ext-enable protobuf && \
	docker-php-ext-enable memcached && \
	docker-php-ext-enable xlswriter && \
	docker-php-ext-configure opcache --enable-opcache && \
	docker-php-ext-install opcache	&& \
# install composer
 	cd /tmp && \
	curl -O https://getcomposer.org/download/2.1.9/composer.phar -L && \
	chmod u+x composer.phar && \
	mv composer.phar /usr/local/bin/composer && \
# show php version and extensions
	php -v && \
	php -m && \
# install swoole:4.5.2
	mkdir -p /usr/local/swoole/modules && \
	mkdir -p /etc/supervisor.d && \
	cd /usr/local/swoole && \
	apk add --no-cache libstdc++ supervisor tzdata && \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev && \
	curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz && \
#php extension:swoole
	tar -xf swoole.tar.gz --strip-components=1 && \
        phpize && \
        ./configure --enable-mysqlnd --enable-openssl --enable-http2 --enable-sockets && \
        make -s -j$(nproc) && make install && \
	echo "memory_limit=1G" > /usr/local/etc/php/conf.d/00_default.ini && \
    	echo "extension=swoole.so" > /usr/local/etc/php/conf.d/50_swoole.ini && \
    	echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/50_swoole.ini && \
	cp -r /usr/local/bin/php /usr/bin/php && \
	ls -la /etc/php7/conf.d && \
	rm -rf /etc/php7/php.ini && \
#trie-filter install
	cd /tmp && \
	wget https://linux.thai.net/pub/thailinux/software/libthai/libdatrie-0.2.9.tar.xz && \
	tar -xvf libdatrie-0.2.9.tar.xz && \
	cd libdatrie-0.2.9 && \
	./configure && \
	make && \
	make install && \
	mkdir -p /usr/local/trie-filte && \
	cd /usr/local/trie-filte && \
	wget https://github.com/wulijun/php-ext-trie-filter/archive/master.zip && \
	unzip master.zip && \
	cd php-ext-trie-filter-master && \
	phpize && \
	./configure && \
	make && \
	make install && \
	echo 'extension=trie_filter.so' > /usr/local/etc/php/conf.d/100_trie-filter.ini && \
#clear works
	docker-php-source delete && \
	rm -rf /tmp/pear ~/.pearrc  && \
	rm -rf /tmp/* && \
	rm -rf /usr/local/swoole.tar.gz && \
	rm -rf /usr/local/trie-filte/master.zip && \
	rm -rf /usr/local/src && \
	rm -rf /tmp/* && \
	apk del --no-network .fetch-deps

ADD php.ini $PHP_INI_DIR

ADD entrypoint.sh /

EXPOSE ${APP_PORT}

ENTRYPOINT ["sh", "/entrypoint.sh"]
