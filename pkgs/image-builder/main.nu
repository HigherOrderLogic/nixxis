def main [] { }

def "main build" [
    host: string # The host to build
]: nothing -> nothing {
    let cmd = if "CI" in $env { "nix" } else { "nom" }
    ^$cmd build .#nixosConfigurations.($host).config.system.build.isoImage --keep-going
}
