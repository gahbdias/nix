{

  description = "nix configurations";

  #############################################################################
  # inputs
  #############################################################################

  inputs = {
    dream2nix = {
      url = github:nix-community/dream2nix?rev=34a80ab215f1f24068ea9c76f3a7e5bc19478653;
    };
    nixpkgs = {
      # url = github:NixOS/nixpkgs?rev=6c8644fc37b6e141cbfa6c7dc8d98846c4ff0c2e;
      url = github:NixOS/nixpkgs?branch=nixos-22.11;
    };
    home-manager = {
      # url = github:drzln/home-manager?rev=b372d7f8d5518aaba8a4058a453957460481afbc;
      url = github:drzln/home-manager?branch=release-22.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = github:numtide/flake-utils?rev=3db36a8b464d0c4532ba1c7dda728f4576d6d073;
    };
    nix-darwin = {
      url = github:LnL7/nix-darwin?rev=252541bd05a7f55f3704a3d014ad1badc1e3360d;
    };
    pythonix = {
      url = github:Mic92/pythonix?rev=fbc84900b5dcdde558c68d98ab746d76e7884ded;
    };
    sops-nix = {
      url = github:Mic92/sops-nix?rev=c5dab21d8706afc7ceb05c23d4244dcb48d6aade;
    };
    nix-funcs = {
      url = github:t3rro/nix-funcs?rev=1a55a1a80e6e83ec21e5e8e0722a667c42160af6;
    };
    bundix = {
      url = github:nix-community/bundix?rev=3d7820efdd77281234182a9b813c2895ef49ae1f;
      flake = false;
    };
    hydra = {
      url = github:NixOS/hydra?rev=998df1657e7e9bd3c2d54f8106eae5a325e17e02;
    };
    arion = {
      url = github:hercules-ci/arion?rev=09ef2d13771ec1309536bbf97720767f90a5afa7;
    };
    # stitches.url = github:drzln/stitches?ref=main;
    nixt = {
      url = github:nix-community/nixt?rev=02a1f3c32b01ac0c097d6d67f6f5836277d3bcdc;
      flake = false;
    };
    nur = {
      url = github:nix-community/nur?rev=d2d70316f27384cf53e0f3c6cf2fd73e4744555a;
    };
  };

  # end inputs

  #############################################################################
  # outputs
  #############################################################################

  outputs =
    { home-manager
    , flake-utils
    , nix-darwin
    , dream2nix
    , nix-funcs
    , pythonix
    , sops-nix
      # , stitches
    , nixpkgs
    , bundix
    , hydra
    , arion
    , nixt
    , self
    , nur
    }@inputs:
    let
      systems =
        let
          #####################################################################
          # imports
          #####################################################################
          # import some stuff and set values

          inherit (self) outputs;
          funcs = import ./funcs;
          stdenv = pkgs.stdenv;
          home.modules = import ./modules/home-manager;
          node.modules = import ./modules/nixos;
          specialArgs = { inherit inputs outputs stdenv; };
          extraSpecialArgs = specialArgs // { inherit pkgs; };
          localPackages = import ./pkgs extraSpecialArgs;

          # end imports

          #####################################################################
          # func helpers
          #####################################################################

          # make a home configuration structure according to some rules
          mkHomeConfiguration = name: node: pkgs: extraSpecialArgs:
            home-manager.lib.homeManagerConfiguration {
              inherit extraSpecialArgs pkgs;
              modules = [ users/${name}/${node}/home.nix ];
            };

          # end func helpers
          system = "x86_64-linux";

          #####################################################################
          # configure nixpkgs
          #####################################################################

          # This instantiates nixpkgs for each system listed
          # Allowing you to configure it (e.g. allowUnfree)
          # Our configurations will use these instances
          pkgs = legacyPackages.${system};
          legacyPackages = nixpkgs.lib.genAttrs [
            "x86_64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
            (system:
              import inputs.nixpkgs {
                inherit system;
                # NOTE: Using `nixpkgs.config` in your NixOS config won't work
                # Instead, you should set nixpkgs configs here
                # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)

                config.allowUnfree = true;
              }
            );

          # end configure nixpkgs

          #####################################################################
          # home configurations
          # these are exposed to outputs
          #####################################################################

          home.configurations = {
            ###################################################################
            # ubuntu machines
            ###################################################################

            "luis@ego" =
              mkHomeConfiguration "luis" "ego" pkgs extraSpecialArgs;

            ###################################################################
            # PGR AML2
            # my personal amazon-linux 2 box for PGR
            ###################################################################

            # lucas pereira popos support

            "LILU" =
              mkHomeConfiguration "lucas" "LILU" pkgs extraSpecialArgs;

            "tupa" =
              mkHomeConfiguration "root" "tupa" pkgs extraSpecialArgs;

            "tupa-ssm-user" =
              mkHomeConfiguration "ssm-user" "tupa" pkgs extraSpecialArgs;

            # end PGR AML2

            # amazon-linux 2 box for MBG
            "burgundy" =
              mkHomeConfiguration "root" "burgundy" pkgs extraSpecialArgs;

            "luis@rai" =
              mkHomeConfiguration "luis" "rai" pkgs extraSpecialArgs;

            "ldesiqueira@rai" =
              mkHomeConfiguration "ldesiqueira" "rai" pkgs extraSpecialArgs;

            "luis@plo" =
              mkHomeConfiguration "luis" "plo" pkgs extraSpecialArgs;

            "t3rro@rai" =
              mkHomeConfiguration "t3rro" "rai" pkgs extraSpecialArgs;
            "t3rro@plo" =
              mkHomeConfiguration "t3rro" "plo" pkgs extraSpecialArgs;
          };

          # end home configurations

          #####################################################################
          # nixos configurations
          #####################################################################

          node.configurations = rec {

            # coding desktop
            rai = nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules = [
                nodes/rai
              ];
            };

            # gaming desktop
            plo = nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules = [ nodes/plo ];
            };
          };

          # end nixos configurations


          #####################################################################
          # nix-darwin configurations
          #####################################################################

          darwin.configurations = {
            # personal macos laptop
            ani = nix-darwin.lib.darwinSystem {
              specialArgs = {
                inherit outputs;
              };
              system = "x86_64-darwin";
              modules = [
                home-manager.darwinModules.home-manager
                ./nodes/ani
              ];
            };

            # TODO: module to add stitches, consider
            # TODO: making more concise
            # cidStitchesMod = { ... }: {
            #   environment.systemPackages = [
            #     stitches.packages.aarch64-darwin.default
            #   ];
            # };

            # work macos laptop
            cid = nix-darwin.lib.darwinSystem {
              specialArgs = {
                inherit outputs;
              };
              system = "x86_64-darwin";
              modules = [
                home-manager.darwinModules.home-manager
                ./nodes/cid
              ];
            };
          };

          # end nix-darwin configurations
        in
        {
          # attach to outputs so you can access it in nixos module
          # and pass to home-manager modules called by nixos modules
          inherit specialArgs extraSpecialArgs funcs;

          #####################################################################
          # packages
          # offered by outputs
          # access with: outputs.packages.${system}.${pname}
          #####################################################################

          packages =
            {
              x86_64-darwin =
                flake-utils.lib.flattenTree
                  localPackages;
              x86_64-linux =
                flake-utils.lib.flattenTree
                  localPackages;
              aarch64-darwin =
                flake-utils.lib.flattenTree
                  localPackages;
            };

          # end packages

          #####################################################################
          # expose to outputs
          # expose these things to nix flake show
          # also to anything that uses this flake
          # also to internal modules via outputs
          #####################################################################

          homeManagerModules = home.modules;
          homeConfigurations = home.configurations;
          nixosModules = node.modules;
          nixosConfigurations = node.configurations;
          darwinConfigurations = darwin.configurations;

          # end expose to outputs
        };
    in
    systems;
  # end outputs
}
