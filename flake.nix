{
  description = "dev shell";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.zig.url = "github:mitchellh/zig-overlay";
  inputs.zls.url = "github:zigtools/zls";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    overlays = [
      (final: prev: {
        zigpkgs = inputs.zig.packages.${prev.system};
        zls = inputs.zls.packages.${prev.system}.zls;
      })
    ];
    # Our supported systems are the same supported systems as the Zig binaries
    systems = builtins.attrNames inputs.zig.packages;
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {inherit overlays system; };
        luaenv = with pkgs.lua51Packages; [ penlight basexx cjson ];
      in rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # In zigpkgs.master-<date> the <date> doesn't correspond the the
            # actual zig master's date of a commit. e.g
            # for master-2023-05-18: package 'zig-0.11.0-dev.3220+447a30299'
            # doing a git show 447a30299 in the zig lang repo will show a
            # different date than 2023-05-18. The zig commit date for
            # master-2023-05-18 is actually 0.11.0-dev.3202+378264d40 which is
            # commit 378264d404e71da878f9e6934c045ad64193877f
            # Merge: 6e0562011 f52189834
            # Author: Andrew Kelley <andrew@ziglang.org>
            # Date:   Wed May 17 23:28:35 2023 -0700
            zigpkgs.master-2023-05-18
            zls
          ];

          buildInputs = with pkgs; [
            bashInteractive 
          ];

          shellHook = ''
            export SHELL=${pkgs.bashInteractive}/bin/bash
          '';
        };
        devShell = self.devShells.${system}.default;
      }
    );
}
