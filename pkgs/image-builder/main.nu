def main [] { }

def "main build" [
    host: string # The host to build
]: nothing -> nothing {
    nh os build-image . -H $host ...(if "CI" in $env { ["--no-rom"] } else { [] }) -- --keep-going
}
