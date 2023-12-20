FROM rust:1.73.0 AS builder

WORKDIR /app

# Build dependencies
COPY Cargo.toml Cargo.lock /app
RUN <<EOF
  mkdir src
  echo 'fn main() {}' > src/main.rs
  cargo build --release
  rm -rf src
EOF

# Build app
COPY src /app/src
RUN <<EOF
  touch src/main.rs
  cargo build --bins --release
EOF

FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/target/release/template /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/template"]
