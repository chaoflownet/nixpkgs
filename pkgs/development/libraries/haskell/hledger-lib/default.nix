{ cabal, cmdargs, csv, filepath, HUnit, mtl, parsec, prettyShow
, regexCompat, regexpr, safe, split, testFramework
, testFrameworkHunit, time, transformers, utf8String
}:

cabal.mkDerivation (self: {
  pname = "hledger-lib";
  version = "0.21.3";
  sha256 = "1vvki1dg98f8r9w6gmblazkbin7g2hzifwqd1frb0a3kp869i870";
  buildDepends = [
    cmdargs csv filepath HUnit mtl parsec prettyShow regexCompat
    regexpr safe split time transformers utf8String
  ];
  testDepends = [
    cmdargs csv filepath HUnit mtl parsec prettyShow regexCompat
    regexpr safe split testFramework testFrameworkHunit time
    transformers
  ];
  meta = {
    homepage = "http://hledger.org";
    description = "Core data types, parsers and utilities for the hledger accounting tool";
    license = "GPL";
    platforms = self.ghc.meta.platforms;
    maintainers = [
      self.stdenv.lib.maintainers.andres
      self.stdenv.lib.maintainers.simons
    ];
  };
})
