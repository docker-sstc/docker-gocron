FROM golang:1.18 as builder

ENV GOCRON_VERSION=1.5.3
ENV GOCRON_SOURCE_DOWNLOAD_URL=https://github.com/ouqiang/gocron/archive/refs/tags/v${GOCRON_VERSION}.tar.gz
ENV GOCRON_DOWNLOAD_URL=https://github.com/ouqiang/gocron/releases/download/v${GOCRON_VERSION}/gocron-node-v${GOCRON_VERSION}-linux-amd64.tar.gz
ENV GOCRON_NODE_DOWNLOAD_URL=https://github.com/ouqiang/gocron/releases/download/v${GOCRON_VERSION}/gocron-v${GOCRON_VERSION}-linux-amd64.tar.gz
ENV CERTSTRAP_VERSION=1.3.0
ENV CERTSTRAP_DOWNLOAD_URL=https://github.com/square/certstrap/releases/download/v${CERTSTRAP_VERSION}/certstrap-linux-amd64

WORKDIR /tmp
RUN set -ex; \
	apt-get update; \
	apt-get install -y \
	nodejs npm \
	; \
	apt-get remove cmdtest; \
	npm install -g yarn; \
	git clone https://github.com/up9cloud/gocron.git; \
	# git checkout tags/v${GOCRON_VERSION}; \
	# curl -sSL ${GOCRON_SOURCE_DOWNLOAD_URL} -o gocron.tar.gz; \
	# tar -xvf gocron.tar.gz; \
	cd gocron
ARG TARGETARCH
RUN set -ex; \
	cd gocron; \
	yarn config set ignore-engines true; \
	make install-vue; \
	make build-vue; \
	make statik; \
	echo "Current arch: $TARGETARCH"; \
	GOARCH=$TARGETARCH CGO_ENABLED=0 make gocron; \
	GOARCH=$TARGETARCH CGO_ENABLED=0 make node
RUN set -ex; \
	# curl -sSL ${GOCRON_DOWNLOAD_URL} -o gocron.tar.gz; \
	# tar -xvf gocron.tar.gz; \
	# curl -sSL ${GOCRON_NODE_DOWNLOAD_URL} -o gocron-node.tar.gz; \
	# tar -xvf gocron-node.tar.gz; \
	curl -sSL ${CERTSTRAP_DOWNLOAD_URL} -o certstrap; \
	chmod +x certstrap; \
	chown -R root:root .

FROM sstc/headful-chromium:latest
RUN set -ex; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
		tini \
		iputils-ping \
		dnsutils \
		rsync \
		curl \
		jq \
	; \
	# In the mean time, install all famous script languages
	curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
		php \
		ruby \
		lua5.3 \
	; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*

RUN set -e; \
	npm -g install \
		node-fetch

ENTRYPOINT ["tini", "--"]

COPY --from=builder /tmp/gocron/bin/gocron /gocron/gocron
COPY --from=builder /tmp/gocron/bin/gocron-node /gocron/gocron-node
COPY --from=builder /tmp/certstrap /gocron/certstrap
COPY gocron-all.sh /gocron/gocron-all.sh
COPY init-cert.sh /gocron/init-cert.sh

WORKDIR /gocron
VOLUME [ "/gocron/conf", "/gocron/log", "/gocron/out" ]
EXPOSE 5920
EXPOSE 5921
CMD ["/gocron/gocron-all.sh"]
