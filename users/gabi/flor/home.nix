{ outputs, pkgs, ... }:
{
  imports = [
    outputs.homeManagerModules.blackmatter
    ../../gabi/common
    ../common
  ];
  nixpkgs.overlays = [
    (self: super: {
      fcitx-engines = self.fcitx5;
    })
  ];
  blackmatter.programs.nvim.enable = true;
  blackmatter.shell.enable = true;
  blackmatter.desktop.enable = false;
  blackmatter.desktop.alacritty.config.enable = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "python3.10-requests-2.28.2"
  ];
}
