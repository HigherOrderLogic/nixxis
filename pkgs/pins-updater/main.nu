# nu-lint-ignore-file: explicit_long_flags

$env.NPINS_DIRECTORY = "pins"

def main [] { }

def sources-file []: nothing -> string {
    $"($env.NPINS_DIRECTORY)/sources.json"
}

def pin-spec [pin: string]: nothing -> record {
    open (sources-file) | get pins | get $pin # nu-lint-ignore: catch_builtin_error_try, unsafe_dynamic_record_access
}

# List pins in lockfile.
def "main list" []: nothing -> string {
    open (sources-file) | get pins | columns | sort | to json --raw # nu-lint-ignore: catch_builtin_error_try
}

# Update a pin.
def "main update" [
    pin: string # The pin to update.
]: nothing -> nothing {
    let old_spec = pin-spec $pin
    let repo = $old_spec | get -o repository
    let is_git = ($old_spec | get -o type) == Git
    let is_github = $is_git and ($repo != null) and (($repo | get -o type) == GitHub)

    npins update $pin

    let default_body = $"Automatic pin `($pin)` update."
    let body = if $is_github {
        let old_rev = $old_spec | get -o revision
        let owner = $repo | get -o owner
        let repo_name = $repo | get -o repo
        let new_spec = pin-spec $pin
        let new_rev = $new_spec | get -o revision

        if ($owner != null) and ($repo_name != null) and ($old_rev != null) and ($new_rev != null) and ($old_rev != $new_rev) {
            [
                $default_body
                ""
                $"Diff: [($old_rev | str substring 0..6)...($new_rev | str substring 0..6)]\(https://github.com/($owner)/($repo_name)/compare/($old_rev)...($new_rev))"
            ] | str join "\n"
        } else { $default_body }
    } else { $default_body }

    if "GITHUB_OUTPUT" in $env {
        let delimiter = "__BODY__"
        [$"body<<($delimiter)" $body $delimiter] | str join "\n" | $"($in)\n" | save --append $env.GITHUB_OUTPUT # nu-lint-ignore: catch_builtin_error_try
    }
}
