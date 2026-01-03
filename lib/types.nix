{lib}: {
  listOfLength = ty: len: lib.types.addCheck (lib.types.listOf ty) (l: builtins.length l == len);
}
