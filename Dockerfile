FROM digitalocean/doctl:1-latest

LABEL org.opencontainers.image.title="cyber-do"
LABEL org.opencontainers.image.description="Nuke a whole some resources in a DigitalOcean account."
LABEL org.opencontainers.image.authors="Ciro Mota <github.com/ciro-mota> (@ciro-mota)"
LABEL org.opencontainers.image.url="https://github.com/ciro-mota/cyber-do"
LABEL org.opencontainers.image.documentation="https://github.com/ciro-mota/cyber-do/README.md"
LABEL org.opencontainers.image.source="https://github.com/ciro-mota/cyber-do"

WORKDIR /home

COPY ./scripts /home

RUN chmod +x /home/*.sh \
	&& ln -s /app/doctl /usr/local/bin/doctl

ENTRYPOINT ["/bin/sh"]
CMD ["./cyber-do.sh"]