# Srid's Claude Code Configuration

## Nix module

- `nix/home-manager-module.nix` - Home-manager module for auto-wiring this directory layout.

### Usage

Add as flake input:

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

