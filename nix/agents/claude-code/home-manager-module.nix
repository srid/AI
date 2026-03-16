{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claude-code;

  autoDirs = cfg.autoWire.dirs;
  autoWireEnabled = autoDirs != [ ] && cfg.autoWire.enable;

  readAgents = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readCommands = dir:
    let path = toString dir + "/commands";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readSkills = dir:
    let path = toString dir + "/skills";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (skillName: _:
          lib.nameValuePair
            skillName
            (path + "/" + skillName)
        )
        (lib.filterAttrs (_: type: type == "directory") (builtins.readDir path)));

  readMcpServers = dir:
    let path = toString dir + "/mcp";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".nix" fileName)
            (import (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readSettings = dir:
    let path = toString dir + "/settings/claude-code.nix";
    in lib.optionalAttrs (builtins.pathExists path)
      (import path);

  readMemory = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalAttrs (builtins.pathExists path)
      { text = builtins.readFile path; };

  autoAgents = lib.foldl' lib.mergeAttrs { } (map readAgents autoDirs);
  autoCommands = lib.foldl' lib.mergeAttrs { } (map readCommands autoDirs);
  autoSkills = lib.foldl' lib.mergeAttrs { } (map readSkills autoDirs);
  autoMcpServers = lib.foldl' lib.mergeAttrs { } (map readMcpServers autoDirs);
  autoSettings = lib.foldl' lib.mergeAttrs { } (map readSettings autoDirs);
  autoMemory = lib.foldl' lib.mergeAttrs { } (map readMemory autoDirs);

in
{
  options.programs.claude-code = {
    autoWire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically wire up agents, commands, skills, and MCP servers from autoWire.dirs.
          Set to false if you want to manually configure these.
        '';
      };

      dirs = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = ''
          List of directories containing agents/, commands/, skills/, mcp/, settings/claude-code.nix, and memory.md.
          All directories are merged, with later directories taking precedence.
        '';
      };
    };
  };

  config = lib.mkIf autoWireEnabled {
    programs.claude-code = {
      enable = lib.mkDefault true;

      settings = lib.mkDefault autoSettings;

      memory = lib.mkDefault autoMemory;

      commands = lib.mkDefault autoCommands;

      agents = lib.mkDefault autoAgents;

      skills = lib.mkMerge [
        (lib.mkIf (autoSkills != { }) autoSkills)
      ];

      mcpServers = lib.mkDefault autoMcpServers;
    };
  };
}
