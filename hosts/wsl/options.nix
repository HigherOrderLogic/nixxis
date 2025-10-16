{
  cfg = {
    core.username = "kamn";
    profiles.wsl.enable = true;
    programs = {
      fish.enable = true;
      git = {
        enable = true;
        name = "HigherOrderLogic";
        email = "73709188+HigherOrderLogic@users.noreply.github.com";
      };
      helix = {
        enable = true;
        defaultEditor = true;
        trueColor = true;
      };
      nh.enable = true;
    };
  };
}
