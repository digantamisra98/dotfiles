{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # treehouse: git worktree pool manager (Go), installed from its own flake.
    treehouse.url = "github:kunchenguid/treehouse";
    treehouse.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs, ... }:
    let
      # Read the username from the environment at evaluation time, so the same
      # branch builds on any machine with no per-machine edits. SUDO_USER wins
      # because darwin-rebuild runs under sudo, where USER is "root".
      # getEnv needs impure evaluation - rebuild.sh and bootstrap.sh pass --impure.
      sudoUser = builtins.getEnv "SUDO_USER";
      envUser = builtins.getEnv "USER";
      user =
        if sudoUser != "" then sudoUser
        else if envUser != "" && envUser != "root" then envUser
        else throw "Cannot determine the username: run via ./rebuild.sh, or pass --impure so flake.nix can read $USER.";
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Rename any pre-existing dotfile (e.g. a hand-written ~/.zshrc) to
            # <name>.backup instead of refusing to overwrite it. Lets the first
            # switch adopt a machine that already had these files.
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit user inputs; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    };
}
