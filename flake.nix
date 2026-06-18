{
  description = "rust-build — shared Nix build policy for LiGoldragon Rust repositories";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    { self, nixpkgs, flake-utils, fenix, crane }:
    let
      defaultSystems = flake-utils.lib.defaultSystems;
    in
    {
      lib = nixpkgs.lib.genAttrs defaultSystems (
        system:
        import ./lib {
          inherit crane fenix system;
        }
      );
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        rust = self.lib.${system}.fromPkgs pkgs;
        cargoFilter = rust.sourceFilter { };
        schemaFilter = path: type: type == "regular" && pkgs.lib.hasSuffix ".schema" (toString path);
        sourceFilter = rust.sourceFilter { extraFilters = [ schemaFilter ]; };
        policyAssertions = [
          {
            name = "target directory is pruned";
            assertion = sourceFilter "/tmp/example/target" "directory" == false;
          }
          {
            name = ".git directory is pruned";
            assertion = sourceFilter "/tmp/example/.git" "directory" == false;
          }
          {
            name = ".jj directory is pruned";
            assertion = sourceFilter "/tmp/example/.jj" "directory" == false;
          }
          {
            name = "Cargo.toml stays in cargo source";
            assertion = cargoFilter "/tmp/example/Cargo.toml" "regular" == true;
          }
          {
            name = "schema extras can be included";
            assertion = sourceFilter "/tmp/example/schema/root.schema" "regular" == true;
          }
          {
            name = "unlisted generated object is excluded";
            assertion = sourceFilter "/tmp/example/target/debug/deps/cache.o" "regular" == false;
          }
        ];
        failedAssertions = builtins.filter (item: !item.assertion) policyAssertions;
      in
      {
        checks.source-prune-policy =
          assert failedAssertions == [ ];
          pkgs.runCommand "rust-build-source-prune-policy" { } ''
            touch $out
          '';
      }
    );
}
