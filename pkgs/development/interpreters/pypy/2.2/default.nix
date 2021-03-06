{ stdenv, fetchurl, zlib ? null, zlibSupport ? true, bzip2, pkgconfig, libffi
, sqlite, openssl, ncurses, pythonFull, expat }:

assert zlibSupport -> zlib != null;

let

  majorVersion = "2.2";
  version = "${majorVersion}";
  pythonVersion = "2.7";
  libPrefix = "pypy${majorVersion}";

  pypy = stdenv.mkDerivation rec {
    name = "pypy-${version}";

    inherit majorVersion version;

    src = fetchurl {
      url = "https://bitbucket.org/pypy/pypy/downloads/pypy-${version}-src.tar.bz2";
      sha256 = "0kp0922d1739v3fqnxhrbwz1fg651dc5dmk3199ikq1rc2wgrzsh";
    };

    buildInputs = [ bzip2 openssl pkgconfig pythonFull libffi ncurses expat sqlite ]
      ++ stdenv.lib.optional (stdenv ? gcc && stdenv.gcc.libc != null) stdenv.gcc.libc
      ++ stdenv.lib.optional zlibSupport zlib;

    C_INCLUDE_PATH = stdenv.lib.concatStringsSep ":" (map (p: "${p}/include") buildInputs);
    LIBRARY_PATH = stdenv.lib.concatStringsSep ":" (map (p: "${p}/lib") buildInputs);
    LD_LIBRARY_PATH = LIBRARY_PATH;

    preConfigure = ''
      substituteInPlace Makefile \
        --replace "-Ojit" "-Ojit --batch" \
        --replace "pypy/goal/targetpypystandalone.py" "pypy/goal/targetpypystandalone.py --withmod-_minimal_curses --withmod-unicodedata --withmod-thread --withmod-bz2 --withmod-_multiprocessing"

      # we are using cpython and not pypy to do translation
      substituteInPlace rpython/bin/rpython \
        --replace "/usr/bin/env pypy" "${pythonFull}/bin/python"
      substituteInPlace pypy/goal/targetpypystandalone.py \
        --replace "/usr/bin/env pypy" "${pythonFull}/bin/python"

      # convince pypy to find nix ncurses
      substituteInPlace pypy/module/_minimal_curses/fficurses.py \
        --replace "/usr/include/ncurses/curses.h" "${ncurses}/include/curses.h" \
        --replace "ncurses/curses.h" "${ncurses}/include/curses.h" \
        --replace "ncurses/term.h" "${ncurses}/include/term.h" \
        --replace "libraries=['curses']" "libraries=['ncurses']"
    '';

    setupHook = ./setup-hook.sh;

    doCheck = true;
    checkPhase = ''
       export TERMINFO="${ncurses}/share/terminfo/";
       export TERM="xterm";
       export HOME="$TMPDIR";
       # disable shutils because it assumes gid 0 exists
       # disable socket because it has two actual network tests that fail
      ./pypy-c ./pypy/test_all.py --pypy=./pypy-c -k '-test_socket -test_shutil' lib-python
    '';

    installPhase = ''
       mkdir -p $out/{bin,include,lib,pypy-c}

       cp -R {include,lib_pypy,lib-python,pypy-c} $out/pypy-c
       ln -s $out/pypy-c/pypy-c $out/bin/pypy
       chmod +x $out/bin/pypy

       # other packages expect to find stuff according to libPrefix
       ln -s $out/pypy-c/include $out/include/${libPrefix}
       ln -s $out/pypy-c/lib-python/${pythonVersion} $out/lib/${libPrefix}

       # TODO: compile python files?
    '';

    passthru = {
      inherit zlibSupport libPrefix;
      executable = "pypy";
    };

    enableParallelBuilding = true;

    meta = with stdenv.lib; {
      homepage = "http://pypy.org/";
      description = "PyPy is a fast, compliant alternative implementation of the Python language (2.7.3)";
      license = licenses.mit;
      platforms = platforms.all;
      maintainers = with maintainers; [ iElectric ];
    };
  };

in pypy
