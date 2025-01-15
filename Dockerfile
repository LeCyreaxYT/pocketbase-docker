FROM alpine:3 as downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:3

# Install necessary packages and configure timezone
RUN apk update && apk add --no-cache ca-certificates tzdata \
    && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

EXPOSE 80

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase

# Dynamic command handling
ENTRYPOINT ["/bin/sh", "-c", "exec /usr/local/bin/pocketbase serve --http=0.0.0.0:80 --dir=/pb_data --publicDir=/pb_public --migrationsDir=/pb_migrations ${ORIGINS:+--origins=${ORIGINS}}"]
