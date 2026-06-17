FROM charmcli/soft-serve:latest

# Become root so we can install the options parser and stage the entrypoint.
USER root

# jq parses the HA add-on options (/data/options.json) at runtime.
RUN apk add --no-cache jq

# The image defaults SOFT_SERVE_DATA_PATH to /soft-serve; re-home it onto the
# add-on's persistent /data volume so repos + server state survive rebuilds.
ENV SOFT_SERVE_DATA_PATH=/data

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Base image ENTRYPOINT is ["/usr/local/bin/soft","serve"]. Override it so the
# wrapper can inject admin keys from options.json, then exec the real binary.
ENTRYPOINT ["/run.sh"]
