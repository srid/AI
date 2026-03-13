{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;

  commandsDir = cfg.autoWire.dir + "/commands";
  autoCommands = lib.optionalAttrs (builtins.pathExists commandsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (builtins.readFile (commandsDir + "/${fileName}"))
      )
      (builtins.readDir commandsDir));

  mcpDir = cfg.autoWire.dir + "/mcp";
  autoMcpServers = lib.optionalAttrs (builtins.pathExists mcpDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".nix" fileName)
          (import (mcpDir + "/${fileName}"))
      )
      (builtins.readDir mcpDir));

  settingsFile = cfg.autoWire.dir + "/settings.nix";
  autoSettings = lib.optionalAttrs (builtins.pathExists settingsFile)
    (import settingsFile);

  opencodeConfig = lib.recursiveUpdate
    (lib.optionalAttrs (autoSettings != { }) autoSettings)
    (lib.optionalAttrs (autoMcpServers != { }) { mcpServers = autoMcpServers; });

in
{
  options.programs.opencode = {
    autoWire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically wire up commands and MCP servers from autoWire.dir.
          Set to false if you want to manually configure these.
        '';
      };

      dir = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to the opencode directory containing commands/, mcp/, and settings.nix.
          When set, these will be automatically discovered and configured.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.autoWire.dir != null && cfg.autoWire.enable) {
    home.file = lib.mkMerge [
      (lib.mapAttrs'
        (cmdName: cmdContent:
          lib.nameValuePair ".opencode/commands/${cmdName}.md" {
            text = cmdContent;
          }
        )
        autoCommands)

      (lib.optionalAttrs (opencodeConfig != { }) {
        ".opencode.json".text = builtins.toJSON opencodeConfig;
      })
    ];
  };
}
