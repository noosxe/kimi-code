# kimi-code — Nix Flake

Packages the [Kimi Code](https://kimi.com/code) CLI (`kimi`) as a Nix flake,
using the official pre-built binaries from Moonshot AI.

## Usage

### `nix run` (try it instantly)

```bash
nix run github:noosxe/kimi-code
```

### As a NixOS / home-manager input

Add to your flake inputs:

```nix
inputs.kimi-code.url = "github:noosxe/kimi-code";
```

#### Via the overlay (recommended)

The overlay adds `kimi-code` directly into your `pkgs`, which is the most
idiomatic way to consume it:

```nix
# NixOS (configuration.nix or a module)
nixpkgs.overlays = [ inputs.kimi-code.overlays.default ];
environment.systemPackages = [ pkgs.kimi-code ];

# home-manager
nixpkgs.overlays = [ inputs.kimi-code.overlays.default ];
home.packages = [ pkgs.kimi-code ];
```

#### Via the package output directly

If you prefer not to use an overlay, reference the package output:

```nix
environment.systemPackages = [ inputs.kimi-code.packages.${system}.default ];
# or
home.packages = [ inputs.kimi-code.packages.${system}.default ];
```

### Install into a profile

```bash
nix profile install github:noosxe/kimi-code
```

## Supported platforms

| System            | Platform        |
|-------------------|-----------------|
| `x86_64-linux`    | `linux-x64`     |
| `aarch64-linux`   | `linux-arm64`   |
| `aarch64-darwin`  | `darwin-arm64`  |

> **Note:** Alpine Linux / musl is **not** supported by the upstream binaries.

## Updating

1. Fetch the latest version: `curl https://code.kimi.com/kimi-code/latest`
2. Fetch the manifest: `curl https://code.kimi.com/kimi-code/binaries/<VERSION>/manifest.json`
3. Convert checksums to SRI: `nix-hash --type sha256 --to-sri "sha256:<HEX>"`
4. Update `version` and the `platformMap` hashes in `flake.nix`

## License

The flake packaging scripts are MIT. The `kimi` binary itself is proprietary
software — see the [Kimi Terms of Service](https://kimi.com/code/docs).
