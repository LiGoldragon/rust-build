# rust-build

Shared Nix build policy for LiGoldragon Rust repositories.

Use it from a consumer flake:

```nix
rust-build = {
  url = "github:LiGoldragon/rust-build";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then:

```nix
let
  pkgs = import nixpkgs { inherit system; };
  rust = rust-build.lib.${system}.fromPkgs pkgs;
  craneLib = rust.craneLib;
  schemaFilter = path: type: type == "regular" && pkgs.lib.hasSuffix ".schema" path;
  src = rust.cleanSource {
    root = ./.;
    extraFilters = [ schemaFilter ];
  };
in
# use src and craneLib
```

`cleanSource` prunes `.git`, `.jj`, `.direnv`, `node_modules`, and `target` directories before applying Crane or extra filters.
