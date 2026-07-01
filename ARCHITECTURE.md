# rust-build Architecture

rust-build exports a per-system library at `lib.${system}`.

## Direction

`rust-build` is the shared Nix build policy flake for LiGoldragon Rust repositories. Its primary purpose is source hygiene: Rust builds must not traverse heavyweight local cache and history directories — `target`, `.git`, `.jj`, `.direnv`, `node_modules` — while constructing Nix sources.

Consumers use `rust-build` for the standard Rust toolchain, Crane library, and source-cleaning helpers, layering repo-specific source extras through explicit extra filters. Raw project flakes should not call `craneLib.cleanCargoSource` or `craneLib.filterCargoSources` directly when `rust-build` is available.

Consumers call:

```nix
rust = rust-build.lib.${system}.fromPkgs pkgs;
```

The returned value contains:

- `toolchain` — the standard Fenix stable toolchain with Cargo, rustc, rustfmt, clippy, rust-analyzer, and rust-src;
- `craneLib` — `crane.mkLib pkgs` overridden to use that toolchain;
- `sourceFilter` — a guarded Cargo source predicate;
- `cleanSource` — `pkgs.lib.cleanSourceWith` using that guarded predicate;
- `cleanCargoSource` — a drop-in simple Cargo source cleaner for repos with no extra data filters.

The source guard rejects directory basenames before any include predicate runs:

- `.git`
- `.jj`
- `.direnv`
- `node_modules`
- `target`

This matters because Crane's `filterCargoSources` intentionally allows directories so source traversal can continue. Without a pre-guard, Nix can walk large local `target` or VCS trees even when their files are not included in the final source.
