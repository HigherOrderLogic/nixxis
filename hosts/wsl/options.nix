let
  gitName = "HigherOrderLogic";
  gitEmail = "73709188+HigherOrderLogic@users.noreply.github.com";
in {
  cfg = {
    core.username = "kamn";
    profiles.wsl.enable = true;
    programs = {
      fish.enable = true;
      git = {
        enable = true;
        name = gitName;
        email = gitEmail;
      };
      helix = {
        enable = true;
        defaultEditor = true;
        trueColor = true;
        languages.java.enable = false;
      };
      jj = {
        enable = true;
        name = gitName;
        email = gitEmail;
      };
      nh.enable = true;
    };
  };
}
