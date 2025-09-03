FROM alpine:3.22.1 AS base

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN wget -q https://api.github.com/repos/digitalocean/doctl/releases/latest -O - \
	| grep -E  "browser_download.*linux-amd64" \
	| awk -F '[""]' '{print $4}' \
	| xargs wget -q -P /tmp/ \
	&& tar xf /tmp/doctl*.tar.gz -C /tmp

# hadolint ignore=DL3006
# hadolint ignore=DL3007
FROM cgr.dev/chainguard/wolfi-base:latest

LABEL org.opencontainers.image.title="cyber-do"
LABEL org.opencontainers.image.description="Nuke a whole some resources in a DigitalOcean account."
LABEL org.opencontainers.image.authors="Ciro Mota <github.com/ciro-mota> (@ciro-mota)"
LABEL org.opencontainers.image.url="https://github.com/ciro-mota/cyber-do"
LABEL org.opencontainers.image.documentation="https://github.com/ciro-mota/cyber-do/README.md"
LABEL org.opencontainers.image.source="https://github.com/ciro-mota/cyber-do"

WORKDIR /home
COPY --from=base /tmp/doctl /usr/bin
COPY ./scripts /home

ARG DO_CLI_TOKEN
ENV DO_CLI_TOKEN=$DO_CLI_TOKEN

RUN chmod +x /home/cyber-do.sh \
	&& doctl auth init --access-token "${DO_CLI_TOKEN}"

CMD ["./cyber-do.sh"]
