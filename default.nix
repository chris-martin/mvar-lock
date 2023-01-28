let

sources = import ./nix/sources.nix;
nixos-22-11 = import sources."nixos-22.11" {};
inherit (nixos-22-11) haskell lib symlinkJoin;
inherit (lib) fold composeExtensions concatMap attrValues;

combineOverrides = old:
    fold composeExtensions (old.overrides or (_: _: { }));

sourceOverrides = haskell.lib.packageSourceOverrides {
    mvar-lock = ./mvar-lock;
};

depOverrides = new: old: {
    # x = new.callPackage ./nix/x.nix {};
};

ghc."9.2" = nixos-22-11.haskell.packages.ghc92.override (old: {
    overrides = combineOverrides old [ sourceOverrides depOverrides ];
});

ghc."9.4" = nixos-22-11.haskell.packages.ghc94.override (old: {
    overrides = combineOverrides old [ sourceOverrides depOverrides ];
});

in

symlinkJoin {
    name = "mvar-lock";
    paths = concatMap (x: [x.mvar-lock]) (attrValues ghc);
} // {
    inherit ghc;
    pkgs = nixos-22-11;
}
