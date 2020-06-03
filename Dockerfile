#FROM ubuntu:18.04
#FROM ubuntu:20.04
#FROM ubuntu:19.10
FROM debian:10-slim


ARG RUST_TARGET=x86_64-unknown-linux-musl
#ARG RUST_TARGET=armv7-unknown-linux-musleabihf
#ARG RUST_TARGET=aarch64-unknown-linux-musl

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

RUN curl -fLO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
RUN curl -fLO "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz"
ENV PATH=/home/rust/.cargo/bin:/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
	  rustup target add $RUST_TARGET


