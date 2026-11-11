{writers}: name: opts: script:
writers.writeNuBin name ({
    check = writers.writeNu "nu-check" ''
      def main [file: string] {
        nu-check --debug $file
      }
    '';
  }
  // opts) (
  if builtins.isPath script
  then builtins.readFile script
  else script
)
