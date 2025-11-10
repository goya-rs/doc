FROM rust:slim-trixie as base

RUN rustup default stable && \
    rustup toolchain add nightly && \
    rustup component add rust-src --toolchain nightly

RUN apt update && \
    apt install openssl libssl-dev pkg-config -y && \
    rm -rf /var/lib/apt/lists/*

RUN cargo install --jobs $(nproc) cargo-generate bpf-linker

FROM base as builder

ENV USER=littlejo
WORKDIR /root/

RUN cargo generate --name test-uprobe \
               -d program_type=uprobe \
               -d uprobe_target=/proc/self/exe \
               -d uprobe_fn_name=main=/proc/self/exe \
               https://github.com/aya-rs/aya-template

WORKDIR /root/test-uprobe

ENV CARGO_TARGET_DIR=/root/build-cache
ENV CARGO_HOME=/root/cargo-home
RUN cargo build

FROM base as final
ENV CARGO_TARGET_DIR=/root/build-cache
ENV CARGO_HOME=/root/cargo-home
ENV USER=littlejo
ENV RUST_LOG=info

COPY --from=builder /root/build-cache /root/build-cache
COPY --from=builder /root/cargo-home /root/cargo-home

RUN apt update && \
    apt install curl sudo golang bpftrace -y && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
