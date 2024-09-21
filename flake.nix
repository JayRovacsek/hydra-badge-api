{
  description = "A very basic flake";

  inputs = {
    nix-inputs.url = "github:jayrovacsek/nix-inputs";
  };

  outputs =
    { self, nix-inputs, ... }:
    nix-inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nix-inputs.nixpkgs {
          overlays = [
            nix-inputs.devshell.overlays.default
          ];
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

        checks.git-hooks = nix-inputs.git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            actionlint.enable = true;

            deadnix = {
              enable = true;
              settings.edit = true;
            };

            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };

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
                ignored-words =
                  [
                  ];
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
    );
}
