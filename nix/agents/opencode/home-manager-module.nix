{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;

  autoDirs = cfg.autoWire.dirs;
  autoWireEnabled = autoDirs != [ ] && cfg.autoWire.enable;

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

  readAgents = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (path + "/" + fileName)
        )
        (builtins.readDir path));

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

  readRules = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalString (builtins.pathExists path)
      (builtins.readFile path);

  autoCommands = lib.foldl' lib.mergeAttrs { } (map readCommands autoDirs);
  autoSkills = lib.foldl' lib.mergeAttrs { } (map readSkills autoDirs);
  autoAgents = lib.foldl' lib.mergeAttrs { } (map readAgents autoDirs);
  autoMcpServers = lib.foldl' lib.mergeAttrs { } (map readMcpServers autoDirs);
  autoRules = lib.concatStringsSep "\n\n" (lib.filter (s: s != "") (map readRules autoDirs));

in
{
  options.programs.opencode.autoWire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically wire up commands, skills, agents, MCP servers, and rules from autoWire.dirs.
        Set to false if you want to manually configure these.
      '';
    };

    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        List of directories containing commands/, skills/, agents/, mcp/, and memory.md.
        All directories are merged, with later directories taking precedence.
      '';
    };
  };

  config = lib.mkIf autoWireEnabled {
    programs.opencode = {
      enable = lib.mkDefault true;
      enableMcpIntegration = lib.mkDefault true;

      commands = lib.mkIf (autoCommands != { }) (lib.mkDefault autoCommands);

      skills = lib.mkMerge [
        (lib.mkIf (autoSkills != { }) autoSkills)
      ];

      agents = lib.mkIf (autoAgents != { }) (lib.mkDefault autoAgents);

      rules = lib.mkIf (autoRules != "") (lib.mkDefault autoRules);
    };

    programs.mcp = {
      enable = lib.mkDefault true;
      servers = autoMcpServers;
    };
  };
}
