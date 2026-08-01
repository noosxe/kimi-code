{
  description = "Kimi Code — AI coding agent CLI by Moonshot AI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem
      [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };

          version = "0.31.1";

          # Map Nix system strings to kimi-code platform identifiers + checksums
          platformMap = {
            "x86_64-linux"   = { platform = "linux-x64";    sha256 = "sha256-ppKMagikvqvuyhpDmFzsXBpfvok7j47UJ8fdjmfmOFA="; };
            "aarch64-linux"  = { platform = "linux-arm64";  sha256 = "sha256-QL3gBq8pxVl6mEV+218lAA54qP4zp1qxnnJMEJLMzKA="; };
            "x86_64-darwin"  = { platform = "darwin-x64";   sha256 = "sha256-z/wOO9SllXJIRWu/7qPuCutUkLHxa0ClRZ9Js4ya/qo="; };
            "aarch64-darwin" = { platform = "darwin-arm64"; sha256 = "sha256-jyQD7dyCIp1Fk+DpuqLvnlE5AiHr/oLqp1dSHynEVPw="; };
          };

          platformInfo = platformMap.${system};

          src = pkgs.fetchurl {
            url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-${platformInfo.platform}";
            inherit (platformInfo) sha256;
          };

          # Linux: patch ELF interpreter + rpath, add libstdc++ (Node.js SEA binary)
          kimi-code-linux = pkgs.stdenv.mkDerivation {
            pname = "kimi-code";
            inherit version src;

            nativeBuildInputs = [ pkgs.autoPatchelfHook ];

            buildInputs = [
              pkgs.stdenv.cc.cc.lib  # libstdc++.so.6
              pkgs.glibc              # libc, libdl, libm, libpthread
            ];

            dontUnpack = true;
            dontBuild = true;
            dontConfigure = true;

            installPhase = ''
              runHook preInstall

              install -Dm755 "$src" "$out/bin/kimi"

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Kimi Code AI coding agent CLI (Moonshot AI)";
              homepage    = "https://kimi.com/code";
              license     = licenses.unfree;
              platforms   = [ "x86_64-linux" "aarch64-linux" ];
              mainProgram = "kimi";
              sourceProvenance = [ sourceTypes.binaryNativeCode ];
            };
          };

          # macOS: pre-built Mach-O binary, no patching needed
          kimi-code-darwin = pkgs.stdenv.mkDerivation {
            pname = "kimi-code";
            inherit version src;

            dontUnpack = true;
            dontBuild = true;
            dontConfigure = true;

            installPhase = ''
              runHook preInstall

              install -Dm755 "$src" "$out/bin/kimi"

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Kimi Code AI coding agent CLI (Moonshot AI)";
              homepage    = "https://kimi.com/code";
              license     = licenses.unfree;
              platforms   = [ "x86_64-darwin" "aarch64-darwin" ];
              mainProgram = "kimi";
              sourceProvenance = [ sourceTypes.binaryNativeCode ];
            };
          };

          kimi-code =
            if pkgs.stdenv.isLinux  then kimi-code-linux
            else if pkgs.stdenv.isDarwin then kimi-code-darwin
            else throw "kimi-code: unsupported system ${system}";

        in
        {
          packages = {
            kimi-code = kimi-code;
            default   = kimi-code;
          };

          apps.default = flake-utils.lib.mkApp {
            drv = kimi-code;
            exePath = "/bin/kimi";
          };
        });
}
