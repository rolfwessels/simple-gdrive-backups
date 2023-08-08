FROM alpine:3.18.3
WORKDIR /app

ARG  VERSION=0.0.0
ARG  VERSION_SUFFIX=pre-alpha

LABEL simple-gdrive-backups-version="${VERSION}"
LABEL simple-gdrive-backups-version-suffix="${VERSION_SUFFIX}"
LABEL simple-gdrive-backups-maintainer="Rolf Wessels"

VOLUME [ "/data/source" ]
VOLUME [ "/data/backup" ]


RUN apk update && apk add --no-cache zip curl
COPY backup-runner.sh /backup-runner.sh
COPY start.sh /start.sh
RUN chmod +x /backup-runner.sh
RUN touch /var/log/simple-gdrive-backups.log


CMD ["sh","/start.sh"]
