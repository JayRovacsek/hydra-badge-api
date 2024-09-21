{
  description = "A reimplementation of the Hydra badge API";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/git-hooks.nix";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      devshell,
      flake-utils,
      git-hooks,
      nixpkgs,
      self,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          overlays = [ devshell.overlays.default ];
          inherit system;
        };
      in
      {
        apps.generate-client-code = {
          program = "${pkgs.writers.writeBash "run" ''
            ${pkgs.coreutils}/bin/mkdir -p src/hydra-client
            ${pkgs.coreutils}/bin/cp -nru ${self.packages.${system}.hydra-client}/share src/hydra-client
          ''}";
          type = "app";
        };

        checks.git-hooks = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            actionlint.enable = true;

            deadnix = {
              enable = true;
              settings.edit = true;
            };

            nixfmt-rfc-style.enable = true;

            prettier = {
              enable = true;
              settings = {
                ignore-path = [ self.packages.${system}.prettierignore ];
                write = true;
              };
            };

            statix.enable = true;

            typos = {
              enable = true;
              settings = {
                binary = false;
                ignored-words = [ ];
                locale = "en-au";
              };
            };

            statix-write = {
              enable = true;
              name = "Statix Write";
              entry = "${pkgs.statix}/bin/statix fix";
              language = "system";
              pass_filenames = false;
            };

            trufflehog-verified = {
              enable = pkgs.stdenv.isLinux;
              name = "Trufflehog Search";
              entry = "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --only-verified --fail --no-update";
              language = "system";
              pass_filenames = false;
            };
          };
        };

        devShells.default = pkgs.devshell.mkShell {
          commands = [
            {
              command = "${pkgs.lix}/bin/nix run .#generate-client-code";
              help = "Generates client code from the Hydra API spec";
              name = "generate-client-code";
            }
          ];
          devshell.startup.git-hooks.text = self.checks.${system}.git-hooks.shellHook;
          name = "dev-shell";
          packages = with pkgs; [
            deadnix
            git-cliff
            nixfmt-rfc-style
            nodejs_20
            nodePackages.prettier
            nodePackages.typescript
            statix
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;

        packages = {
          hydra-client = pkgs.stdenvNoCC.mkDerivation {
            name = "hydra-client";
            version = "0.0.1";

            src = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/NixOS/hydra/master/hydra-api.yaml";
              hash = "sha256-OZk9Yl0t7mz8qqD1SF/jkfQ/K/g91bMsVRt/S3zOndY=";
            };

            dontUnpack = true;

            phases = [ "buildPhase" ];

            buildPhase = ''
              ${pkgs.coreutils}/bin/mkdir -p $out/share
              ${pkgs.swagger-codegen3}/bin/swagger-codegen3 generate -i $src -o $out/share -l typescript-axios
              pushd $out/share
              ${pkgs.coreutils}/bin/rm -rf .npmignore .swagger-codegen .gitignore .swagger-codegen-ignore git_push.sh package.json tsconfig.json README.md
              ${pkgs.gnused}/bin/sed -i '1s;^;// @ts-nocheck\n;' $out/share/models/jobset-eval-builds.ts
            '';
          };

          hydra-badge-api =
            let
              package = builtins.fromJSON (builtins.readFile ./package.json);
            in
            pkgs.buildNpmPackage {
              inherit (package) version;
              pname = package.name;
              src = self;
              npmDepsHash = "sha256-6TsJzZJBG3OSTmMc0uRxq/4/hTfI47xHtWlttIYXaiQ=";
            };

          prettierignore = pkgs.writeTextFile {
            name = ".prettierignore";
            text = ''
              **/hydra-client/**
            '';
          };
        };
      }
    )
    // {
      nixosModules = {
        default = self.nixosModules.hydra-badge-api;

        hydra-badge-api =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            cfg = config.services.hydra.badgeApi;
            inherit (pkgs) system;
          in
          {
            options = {
              services.hydra.badgeApi = {
                enable = lib.mkEnableOption "Enable an opinionated reimplementation of the Hydra badge API";

                group = lib.mkOption {
                  type = lib.types.str;
                  default = "hydra-badge-api";
                  description = "Group under which the API runs";
                };

                instance = lib.mkOption {
                  description = "Base hydra instance to query";
                  default = "https://hydra.nixos.org";
                  type = lib.types.str;
                };

                nodePackage = lib.mkOption {
                  default = pkgs.nodejs_latest;
                  type = lib.types.package;
                };

                openFirewall = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                };

                package = lib.mkOption {
                  default = self.packages.${system}.hydra-badge-api;
                  type = lib.types.package;
                };

                port = lib.mkOption {
                  description = "Port to be utilised by the extended API";
                  default = 8080;
                  type = lib.types.port;
                };

                user = lib.mkOption {
                  type = lib.types.str;
                  default = "jellyfin";
                  description = "User account under which the API runs";
                };
              };
            };

            config = lib.mkIf cfg.enable {
              networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

              systemd.services.hydra-badge-api = {
                description = "Extended Hydra Badge API";
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                wantedBy = [ "multi-user.target" ];

                environment = {
                  PORT = builtins.toString cfg.port;
                  INSTANCE = cfg.instance;
                };

                serviceConfig = {
                  Type = "simple";
                  User = cfg.user;
                  Group = cfg.group;
                  UMask = "0077";
                  # The below surely can be done in a better way - TODO: determine how to present the "main"
                  # executable in this, or wrap the node package as a single executable
                  ExecStart = "${lib.getExe cfg.nodePackage} ${cfg.package}/lib/node_modules/${cfg.package.pname}/dist/index.js";
                  Restart = "on-failure";
                  TimeoutSec = 15;

                  # Security options:
                  NoNewPrivileges = true;
                  SystemCallArchitectures = "native";
                  RestrictNamespaces = true;
                  RestrictRealtime = true;
                  RestrictSUIDSGID = true;
                  ProtectControlGroups = true;
                  ProtectHostname = true;
                  ProtectKernelLogs = true;
                  ProtectKernelModules = true;
                  ProtectKernelTunables = true;
                  LockPersonality = true;
                  PrivateTmp = true;
                  PrivateUsers = true;
                  RemoveIPC = true;
                };
              };

              users.users.${cfg.user} = {
                inherit (cfg) group;
                isSystemUser = true;
              };

              users.groups.${cfg.group} = { };
            };
          };
      };
    };
}
