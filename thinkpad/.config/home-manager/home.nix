{ config, pkgs, ... }:

{
  home.username = "hristo.karamanliev";
  home.homeDirectory = "/home/hristo.karamanliev";

  nix = {
   package = pkgs.nix;
   settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.stateVersion = "25.11";

  targets.genericLinux.enable = true;

  programs.zsh.enable = false;

  home.packages = with pkgs; [
    adw-gtk3
    alacritty
    atuin
    bat
    blueman
    brightnessctl
    btop
    delta
    eza
    fd
    fnm
    fzf
    kitty
    lazydocker
    lazygit
    neovim
    nerd-fonts.symbols-only
    niri
    polkit_gnome
    power-profiles-daemon
    ripgrep
    satty
    sesh
    starship
    sunsetr
    sunshine
    swaynotificationcenter
    tealdeer
    telegram-desktop
    tmux
    uv
    vicinae
    vivid
    waybar
    wpaperd
    yazi
    zoxide
    zsh-autosuggestions
    zsh-completions
    zsh-fast-syntax-highlighting
    (catppuccin-papirus-folders.override {
      flavor = "macchiato";
      accent = "mauve";
    })
    (zsh-autocomplete.overrideAttrs (old: {
      installPhase = ''
        install -D zsh-autocomplete.plugin.zsh \
          $out/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
        cp -R Completions $out/share/zsh/plugins/zsh-autocomplete/Completions
        cp -R Functions $out/share/zsh/plugins/zsh-autocomplete/Functions
        ln -s $out/share/zsh/plugins/zsh-autocomplete \
          $out/share/zsh-autocomplete
      '';
    }))
  ];

  programs.home-manager.enable = true;
}
