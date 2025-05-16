# hadolint ignore=DL3006
# hadolint ignore=DL3007
FROM cgr.dev/chainguard/wolfi-base:latest

WORKDIR /home
COPY ./scripts /home

ARG DO_CLI_TOKEN
ENV DO_CLI_TOKEN=$DO_CLI_TOKEN

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk update \
	&& apk add bash=5.2.37-r30 wget=1.25.0-r1 --no-cache \
	&& wget -q https://api.github.com/repos/digitalocean/doctl/releases/latest -O - \
	| grep -E  "browser_download.*linux-amd64" \
	| awk -F '[""]' '{print $4}' \
	| xargs wget -q -P /tmp/ \
	&& tar xf /tmp/doctl*.tar.gz -C /tmp \
	&& mv /tmp/doctl /usr/bin \
	&& chmod +x /home/cyber-do.sh \
	&& doctl auth init --access-token "${DO_CLI_TOKEN}"

ENTRYPOINT ["/usr/bin/bash"]
CMD ["./cyber-do.sh"]
