{
  pins,
  pkgs,
}:
(
  import "${pins.nix-index-database}/default.nix" {inherit pkgs;}
).comma-with-db
