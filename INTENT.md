# rust-build Intent

rust-build is the shared Nix build policy flake for LiGoldragon Rust repositories.

It exists so Rust repositories do not each hand-roll toolchain, Crane, and source-cleaning behavior. The first durable responsibility is source hygiene: Rust builds must not traverse heavyweight local cache/history directories such as `target`, `.git`, `.jj`, `.direnv`, or `node_modules` while constructing Nix sources.

Consumers should use rust-build for the standard Rust toolchain, Crane library, and source-cleaning helpers, then layer repo-specific source extras such as schema, examples, scripts, or fixtures through explicit extra filters.

Raw project flakes should stop calling `craneLib.cleanCargoSource` or `craneLib.filterCargoSources` directly when they can use rust-build instead.
