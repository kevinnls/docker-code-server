FROM debian:bullseye-slim

RUN apt update && apt install -y --no-install-recommends ca-certificates curl jq \
		    && rm -rf /var/lib/apt/lists /var/cache/apt

# Install code-server
RUN curl -Lo /tmp/cdr.deb "$(curl -L 'https://api.github.com/repos/cdr/code-server/releases/latest' \
	| jq -r '.assets[] | select( .name | contains("amd64.deb") ) | .browser_download_url')" \
	&& apt install /tmp/cdr.deb && rm -rf /tmp/cdr.deb /var/lib/apt/lists /var/cache/apt

# Docker-in-Docker
RUN curl https://get.docker.com/ | sh && rm -rf /var/lib/apt/lists /var/cache/apt

RUN useradd -md/code-server -Uu1000 -k/dev/null -s/bin/bash -Gdocker code-server
RUN mkdir -p /code-server/.local/share/code-server/ && chown 1000:1000 /code-server/.local/share/code-server/

VOLUME /code-server/projects
WORKDIR /code-server/projects

RUN apt update && apt install -y --no-install-recommends \
	mosh openssh-client gnupg git git-crypt git-lfs \
	&& rm -rf /var/lib/apt/lists /var/cache/apt

ENTRYPOINT ["code-server"]
USER code-server

