# AI Code Agent Nix Configuration

This repo provides home-manager modules for auto-wiring AI code agent configurations:

- `homeManagerModules.claude-code` - Claude Code
- `homeManagerModules.opencode` - OpenCode

## Usage

Add as flake input:

```nix
{
  inputs = {
    AI.url = "github:srid/AI";
  };
}
```

### Claude Code

```nix
{
  imports = [
    AI.homeManagerModules.claude-code
  ];

  programs.claude-code = {
    enable = true;
    autoWire.dir = /path/to/your/config;  # Your config directory
  };
}
```

### OpenCode

```nix
{
  imports = [
    AI.homeManagerModules.opencode
  ];

  programs.opencode = {
    enable = true;
    autoWire.dir = /path/to/your/config;  # Your config directory
  };
}
```

## Directory Layout

Both modules use `autoWire` to discover configuration from a directory. See `example/` for a minimal template:

```
example/
├── agents/              # Agent definitions (.md files)
│   └── example.md
├── commands/            # Slash commands (.md files)
│   └── example.md
├── skills/              # Local skill directories
│   └── example/
│       └── SKILL.md
├── mcp/                 # MCP server configs (.nix files)
│   └── example.nix
├── settings/            # Tool-specific settings
│   └── claude-code.nix
└── memory.md            # Persistent memory/context
```

**External Skills:**

Nix skills (`nix-flake`, `nix-haskell`) are provided by [juspay/skills](https://github.com/juspay/skills) and automatically included.

**Both modules autoWire:**

- **commands/*.md** → Slash commands
- **agents/*.md** → Custom agents (use `mode: subagent` in frontmatter for OpenCode)
- **skills/*/** → Skills (symlinked)
- **mcp/*.nix** → MCP server configurations
- **memory.md** → Global rules

**Claude Code only:**

- **settings/claude-code.nix** → `programs.claude-code.settings`

**OpenCode only:**

- Uses `programs.mcp.servers` + `enableMcpIntegration` for MCP
