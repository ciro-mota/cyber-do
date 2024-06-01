FROM alpine:3.20

WORKDIR /home
COPY ./scripts /home

ENV DO_CLI_TOKEN=<your-personal-access-token-here>

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk update \
	&& apk add bash=5.2.26-r0 --no-cache \
	&& wget -q https://api.github.com/repos/digitalocean/doctl/releases/latest -O - \
	| grep -E  "browser_download.*linux-amd64" \
	| awk -F '[""]' '{print $4}' \
	| xargs wget -q -P /tmp/ \
	&& tar xf /tmp/doctl*.tar.gz -C /tmp \
	&& mv /tmp/doctl /usr/local/bin \
	&& chmod +x /home/cyber-do.sh \
	&& doctl auth init --access-token ${DO_CLI_TOKEN} \

ENTRYPOINT ["/bin/bash"]
CMD ["bash", "./cyber-do.sh"]
