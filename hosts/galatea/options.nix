{
  services.automatic-timezoned.enable = true;
  cfg = {
    core = {
      username = "kamn";
      boot.enable = true;
      kernel.type = "zen";
      networking = {
        enable = true;
        stevenblack.enable = true;
      };
    };
    desktops.plasma6.enable = true;
    programs = {
      fish.enable = true;
      foot.enable = true;
      git = {
        enable = true;
        name = "HigherOrderLogic";
        email = "73709188+HigherOrderLogic@users.noreply.github.com";
      };
      helix = {
        enable = true;
        defaultEditor = true;
        languages = {
          python.enable = false;
          java.enable = false;
        };
      };
      nh.enable = true;
    };
    services = {
      flatpak = {
        enable = true;
        packages = ["one.ablaze.floorp"];
      };
      greetd.enable = true;
      pipewire.enable = true;
      scx.enable = true;
    };
  };
}
