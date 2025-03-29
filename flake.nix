{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          self',
          pkgs,
          lib,
          system,
          ...
        }:
        let
          devDeps = with pkgs; [
            watchexec
            zellij
            zola
          ];
          mkDevShell =
            arg1:
            pkgs.mkShell {
              shellHook = ''
                # TODO: figure out if it's possible to remove this or allow a user's preferred shell
                exec env SHELL=${pkgs.bashInteractive}/bin/bash zellij --layout ./zellij_layout.kdl
              '';
              LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
              nativeBuildInputs = devDeps ++ [ arg1 ];
            };
        in
        {
          devShells.default = self'.devShells.stable;

          devShells.stable = (mkDevShell "");
        };
    };
}
