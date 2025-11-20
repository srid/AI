# Srid's Claude Code Configuration

## Nix module

- `nix/home-manager-module.nix` - Home-manager module for auto-wiring this directory layout.

### Usage

Add as flake input:

> [!TIP]
> Since my configuration is in this very repo, I use [git submodules for faster iteration](https://nixos.asia/en/blog/git-submodule-input).

```nix
{
  inputs = {
    AI.url = "github:srid/AI";
    AI.flake = false;
  };
}
```

Import the home-manager module and set `autoWire.dir`:

```nix
{
  imports = [
    "${AI}/nix/home-manager-module.nix"
  ];

  programs.claude-code = {
    enable = true;
    autoWire.dir = AI;
  };
}
```

