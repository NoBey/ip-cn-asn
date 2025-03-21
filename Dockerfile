FROM rust:1.76-slim AS builder

WORKDIR /usr/src/app
COPY . .

RUN cargo build --release

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/ip-cn-asn /usr/local/bin/ip-cn-asn

ENTRYPOINT ["ip-cn-asn"] 