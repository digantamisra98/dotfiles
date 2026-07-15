{ config, pkgs, user, inputs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";

  # no-mistakes: git-push validation proxy. No upstream flake, so install the
  # signed prebuilt release binary directly. This keeps it in the Nix profile via
  # rebuild — no curl installer, nothing in /usr/local, no sudo beyond darwin-rebuild.
  # To bump: change version + hash (nix-prefetch-url the new darwin-arm64 tarball).
  no-mistakes = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "no-mistakes";
    version = "1.37.0";
    src = pkgs.fetchurl {
      url = "https://github.com/kunchenguid/no-mistakes/releases/download/v${version}/no-mistakes-v${version}-darwin-arm64.tar.gz";
      hash = "sha256-jyrIccDKNdrpV78+IOt8r8/V/H3mIsRuXlGQgZJHSaE=";
    };
    sourceRoot = ".";           # tarball is a single flat binary, no wrapping dir
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;           # skip ALL Mach-O post-processing (strip/re-sign); keeps the upstream
                                # Developer ID + hardened-runtime signature valid — arm64 kills a
                                # binary whose signature was invalidated. Nothing to fix in a static Go bin.
    installPhase = ''
      runHook preInstall
      install -Dm755 no-mistakes $out/bin/no-mistakes
      runHook postInstall
    '';
  };
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # git worktree pool manager, from its own flake input
    inputs.treehouse.packages.${pkgs.system}.default
    # git-push validation proxy (prebuilt release binary, defined in the let block above)
    no-mistakes
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      status = "git status";
      push = "git push";
      pull = "git pull";
      gcm = "git commit -m";
      gpp = "git push origin main";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      delds = "find . -type f -name '.DS_Store' -delete";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
