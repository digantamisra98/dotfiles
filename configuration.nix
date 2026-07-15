{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # Adopt a pre-existing Homebrew install instead of erroring out. Inert on a
    # machine nix-homebrew already manages; needed for a clean first switch on a
    # fresh Mac that already had Homebrew (e.g. reproducing this setup elsewhere).
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # Top-level formulae only (from `brew leaves`); dependencies are pulled
    # in automatically, so they are intentionally not listed here.
    brews = [
      "bash"
      "fish"
      "gemini-cli"
      "gh"
      "git"
      "herdr"
      "python@3.14"
      "uv"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "copilot-cli"
    ];
  };
}
