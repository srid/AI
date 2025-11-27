---
name: nix
description: Expert Nix development assistance. Use when working with Nix code, .nix files, flakes, NixOS configuration, or when user mentions Nix, flake-parts, nixpkgs.
---

# Nix Development

## Guidelines

- Use **flake-parts** when creating new flakes
- Format with **nixpkgs-fmt** after changes
- Use **writeShellApplication** for shell scripts (not writeShellScriptBin)
  - Automatically runs ShellCheck validation
  - Sets strict bash options (`set -euo pipefail`)
  - Fix ALL ShellCheck warnings without ignoring them
  - Add **meta.description**

## Building with Nix

When running `nix build`:
- **ALWAYS** use `--print-out-paths` flag so final build path is printed
- **NEVER** run with timeout - allow command to finish completely
- If command doesn't finish OR final out path is not shown, consider it **FAILED**
- On failure, investigate logs without hallucinating - look at actual error messages

## Home-Manager Module

When adding a home-manager module to a project:

1. Module: `nix/modules/home-manager/<name>.nix` - options & config with systemd (Linux) + launchd (Darwin)
2. Export: `nix/modules/flake/<name>-module.nix` - `flake.homeManagerModules.<name> = ../home-manager/<name>.nix;`
3. Example: `nix/examples/home-manager/flake.nix` - homeConfiguration + checks.runNixOSTest
4. CI: Add to `vira.hs` build.flakes: `"./nix/examples/home-manager" { overrideInputs = [("<name>", ".")] }`
5. Format: `nixpkgs-fmt` all .nix files