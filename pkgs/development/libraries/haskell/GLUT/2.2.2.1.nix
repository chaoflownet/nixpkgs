{ cabal, freeglut, libICE, libSM, libXi, libXmu, mesa, OpenGL
, StateVar, Tensor
}:

cabal.mkDerivation (self: {
  pname = "GLUT";
  version = "2.2.2.1";
  sha256 = "09qpkrwpc3w173mvqwda7vi0ncpzzzrnlfa14ja7jba489a8l1mw";
  buildDepends = [ OpenGL StateVar Tensor ];
  extraLibraries = [ freeglut libICE libSM libXi libXmu mesa ];
  meta = {
    homepage = "http://www.haskell.org/haskellwiki/Opengl";
    description = "A binding for the OpenGL Utility Toolkit";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
