#FROM ubuntu:18.04
#FROM ubuntu:20.04
FROM ubuntu:19.10
#FROM debian:10-slim


ARG TARGETPLATFORM
ARG TARGETARCH
ARG TOOLCHAIN=stable
ARG OPENSSL_VERSION=1.1.1f
ARG POSTGRESQL_VERSION=11.8

RUN echo "Hello, my CPU architecture is $(uname -m)"
RUN echo TARGETPLATFORM: $TARGETPLATFORM TARGETARCH: $TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN   apt-get update && apt-get upgrade -y && \
      apt-get install -y \
        build-essential \
	      ca-certificates \
        cmake \
        curl \
        file mc \
        sudo \
	      wget

WORKDIR /tmp

RUN wget "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
RUN wget "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz"

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
	  rustup target add $RUST_TARGET


