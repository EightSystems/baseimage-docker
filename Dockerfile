ARG BASE_IMAGE=alpine:3.16
FROM $BASE_IMAGE

USER root

ARG TARGETARCH
ARG ALPINE_VERSION=3.16

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    ENV="/etc/profile"

COPY ./image/ /bd_build

RUN apk add --no-cache bash && \
    /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh && \
    rm -rf /bd_build && \
    rm -rf /etc/supervisor.d/*.ini

CMD ["/sbin/my_init"]