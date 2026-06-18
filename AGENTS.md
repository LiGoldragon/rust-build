# Agent Bootstrap — rust-build

## Scope

rust-build is the shared Nix build-policy flake for LiGoldragon Rust repositories.

It owns:

- the standard Fenix Rust toolchain component set;
- the standard Crane library construction for consumer `pkgs`;
- source-cleaning policy for Rust repositories, including pruning local cache/history directories before Crane or repo-specific filters run.

## What belongs here

- Pure Nix helpers used by multiple Rust repositories.
- Standard Rust build/check source setup.
- Workspace-wide source hygiene policy for Rust builds.

## What does not belong here

- Repo-specific package definitions.
- Cluster, host, user, deployment, or secret policy.
- Generated source or vendored third-party code.

## Required behavior

- Keep the public API small and stable.
- Consumers pass their own `pkgs`; rust-build must not force a second nixpkgs instance into package construction.
- Prune heavy local directories before calling Crane source filters.
- Use `jj`; commands that set descriptions must pass messages inline.
