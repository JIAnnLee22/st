{
  description = "st - simple terminal (suckless) flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      eachSystem = flake-utils.lib.eachDefaultSystem;
    in
    eachSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        stPkg = pkgs.stdenv.mkDerivation {
          pname = "st";
          version = "0.9.3";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            pkg-config
            ncurses
          ];

          buildInputs = with pkgs; [
            xorg.libX11
            xorg.libXft
            xorg.libXrender
            fontconfig
            freetype
          ];

          makeFlags = [
            "PREFIX=$(out)"
            "APPPREFIX=$(out)/share/applications"
            "MANPREFIX=$(out)/share/man"
          ];

          # 让 tic 把 terminfo 安装到 $out/share/terminfo，
          # 避免在 Nix sandbox 里尝试写 /homeless-shelter/.terminfo
          preInstall = ''
            export TERMINFO="$out/share/terminfo"
            mkdir -p "$TERMINFO"
          '';

          meta = with pkgs.lib; {
            description = "Simple terminal for X which sucks less";
            homepage = "https://st.suckless.org/";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.unix;
          };
        };
      in {
        packages = {
          default = stPkg;
          st = stPkg;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pkg-config
            xorg.libX11
            xorg.libXft
            xorg.libXrender
            fontconfig
            freetype
            ncurses
          ];
        };
      }
    )
    // {
      overlays.default = final: prev: {
        st = self.packages.${final.system}.st;
      };
    };
}

