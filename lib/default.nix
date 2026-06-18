{
  crane,
  fenix,
  system,
}:

let
  defaultToolchainComponents = [
    "cargo"
    "rustc"
    "rustfmt"
    "clippy"
    "rust-analyzer"
    "rust-src"
  ];

  defaultPrunedDirectoryNames = [
    ".git"
    ".jj"
    ".direnv"
    "node_modules"
    "target"
  ];

  directoryBaseName = path: builtins.baseNameOf (toString path);
in
rec {
  inherit defaultPrunedDirectoryNames defaultToolchainComponents;

  fromPkgsWithToolchain =
    pkgs:
    toolchain:
    let
      lib = pkgs.lib;
      craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

      prunedSourceDirectory =
        { pruneDirectories ? defaultPrunedDirectoryNames }:
        path:
        type:
        type == "directory" && builtins.elem (directoryBaseName path) pruneDirectories;

      sourceFilter =
        {
          extraFilters ? [ ],
          pruneDirectories ? defaultPrunedDirectoryNames,
        }:
        path:
        type:
        (!(prunedSourceDirectory { inherit pruneDirectories; } path type))
        && (
          craneLib.filterCargoSources path type
          || lib.any (filter: filter path type) extraFilters
        );

      cleanSource =
        {
          root,
          extraFilters ? [ ],
          name ? "source",
          pruneDirectories ? defaultPrunedDirectoryNames,
        }:
        lib.cleanSourceWith {
          src = root;
          filter = sourceFilter { inherit extraFilters pruneDirectories; };
          inherit name;
        };

      cleanCargoSource = root: cleanSource { inherit root; };
    in
    {
      inherit
        cleanCargoSource
        cleanSource
        craneLib
        prunedSourceDirectory
        sourceFilter
        toolchain
        ;
    };

  fromToolchainFile =
    pkgs:
    toolchainFile:
    let
      toolchain = fenix.packages.${system}.fromToolchainFile toolchainFile;
    in
    fromPkgsWithToolchain pkgs toolchain;

  fromPkgs =
    pkgs:
    let
      toolchain = fenix.packages.${system}.stable.withComponents defaultToolchainComponents;
    in
    fromPkgsWithToolchain pkgs toolchain;
}
