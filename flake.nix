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
        apps = {
          generate-client-code = {
            program = "${pkgs.writers.writeBash "run" ''
              ${pkgs.coreutils}/bin/mkdir -p src/client
              ${pkgs.coreutils}/bin/cp -nru ${self.packages.${system}.hydra-client}/share/* src/client
            ''}";
            type = "app";
          };
        };

        checks.git-hooks = nix-inputs.git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            actionlint.enable = true;

            autogeneration-validation = {
              enable = true;
              name = "${pkgs.lix}/bin/nix run .#generate-client-code";
              entry = self.apps.${system}.generate-client-code.program;
              language = "system";
              pass_filenames = false;
            };

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
          hydra-api-spec = pkgs.stdenvNoCC.mkDerivation {
            name = "hydra-api-spec";
            version = "0.0.1";

            src = pkgs.fetchFromGitHub {
              owner = "NixOS";
              repo = "hydra";
              rev = "master";
              hash = "sha256-F0HJ7xy7874ngU9vZYmqvgJP3jN1+avw8XtgSKFcGTo=";
            };

            phases = [ "buildPhase" ];

            buildPhase = ''
              ${pkgs.coreutils}/bin/mkdir -p $out/share
              ${pkgs.coreutils}/bin/cp $src/hydra-api.yaml $out/share/spec.yml
            '';
          };

          hydra-client = pkgs.stdenvNoCC.mkDerivation {
            name = "hydra-client";
            version = "0.0.1";

            src = self;

            phases = [ "buildPhase" ];

            buildPhase = ''
              ${pkgs.coreutils}/bin/mkdir -p $out/share
              ${pkgs.swagger-codegen3}/bin/swagger-codegen3 generate -i ${
                self.packages.${system}.hydra-api-spec
              }/share/spec.yml -o $out/share -l typescript-axios
              pushd $out/share
              ${pkgs.coreutils}/bin/rm -rf .swagger-codegen .gitignore .swagger-codegen-ignore git_push.sh package.json tsconfig.json README.md
            '';
          };

          prettierignore = pkgs.writeTextFile {
            name = ".prettierignore";
            text = ''
              src/client
            '';
          };
        };

      }
    );
}
