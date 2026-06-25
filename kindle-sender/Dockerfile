FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    pandoc \
    msmtp \
    msmtp-mta \
    ca-certificates \
    python3 \
    curl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# watchexec — mais robusto que inotifywait
RUN curl -sSL \
    https://github.com/watchexec/watchexec/releases/download/v1.25.1/watchexec-1.25.1-x86_64-unknown-linux-musl.tar.xz \
    | tar -xJ --strip-components=1 -C /usr/local/bin \
    watchexec-1.25.1-x86_64-unknown-linux-musl/watchexec

COPY msmtprc /etc/msmtprc
RUN chmod 600 /etc/msmtprc

COPY watch.sh /usr/local/bin/watch.sh
COPY convert-and-send.sh /usr/local/bin/convert-and-send.sh
RUN chmod +x /usr/local/bin/watch.sh /usr/local/bin/convert-and-send.sh

WORKDIR /vault
CMD ["/usr/local/bin/watch.sh"]
