# rust-build Architecture

rust-build exports a per-system library at `lib.${system}`.

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
