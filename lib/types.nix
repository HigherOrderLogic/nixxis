{lib}: {
  listOfLength = ty: len: lib.types.addCheck (lib.types.listOf ty) (l: builtins.length l == len);
  maybeListOf = ty: lib.types.coercedTo (lib.types.either ty (lib.types.listOf ty)) lib.toList (lib.types.listOf ty);
}
