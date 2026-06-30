{
  description = "Development shell for F1R3node Rust blockchain node";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.nightly."2026-02-09".default.override {
          extensions = [ "rustfmt" "clippy" "rust-src" "rust-analyzer" ];
        };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            
            protobuf
            pkg-config
            openssl
            lmdb
            
            just
            grpcurl
            
            gcc
            clang
            cmake
            
            cargo-deny
            
            git
          ];

          shellHook = ''
            export RUST_MIN_STACK=8388608
            export RUSTFLAGS="-C target-cpu=native"
            
            export PROTOC="${pkgs.protobuf}/bin/protoc"
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.lmdb}/lib/pkgconfig"
            export OPENSSL_DIR="${pkgs.openssl.dev}"
            export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
            export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
            
            echo "F1R3node Rust development environment loaded"
            echo "Rust toolchain: nightly-2026-02-09"
            echo "protoc version: $(protoc --version)"
            echo ""
            echo "Available commands:"
            echo "  cargo build           - Build the workspace"
            echo "  cargo test            - Run tests"
            echo "  just run-standalone   - Run standalone node"
            echo "  just --list           - Show all just recipes"
            echo ""
            echo "Stack size: RUST_MIN_STACK=8388608"
          '';

          RUST_BACKTRACE = "1";
          RUST_LOG = "info";
        };
      }
    );
}

