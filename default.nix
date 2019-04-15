with import <nixpkgs> {};

let
  latexPackage = texlive.combine {
    inherit (texlive)
      scheme-small

      # Build packages
      latexmk

      # Basic document
      koma-script
      lipsum
      babel
      enumitem
      bigfoot
      slantsc
      xpatch
      minted
      fvextra
      ifplatform
      framed

      # Bibliography
      biber
      biblatex
      biblatex-apa
      csquotes
      logreq
      xstring
      ;
  };

  pplatex =
    stdenv.mkDerivation rec {
      name = "pplatex-${version}";
      version = "1.0-rc2";

      src = fetchFromGitHub {
        owner = "stefanhepp";
        repo = "pplatex";
        rev = name;
        sha256 = "0xw7nvi2l15iyp9sm8vmmqghi54v99bcivqvx89f5v2gw0kw47k3";
      };

      buildInputs = [ cmake pkgconfig pcre ];

      installPhase = ''
        mkdir -p $out/bin
        cp src/pplatex $out/bin/pplatex
      '';
    };

  mainFile = "main.tex";
  pName = "stgtinf16a-nosql-book";
  pVersion = "0.0.1";

in
  stdenv.mkDerivation rec {
    name = "${pName}-${version}";
    version = pVersion;

    src = ./.;

    buildInputs = [
      latexPackage pplatex
      python3Packages.pygments
      which
    ];

    configurePhase = ''
      # We could be building from an unclean directory, so remove intermediate files first
      latexmk -C
      rm -f "$(basename ${mainFile} .tex).bbl" "$(basename ${mainFile} .tex).run.xml"
    '';

    buildPhase = ''
      latexmk -pdflatex="pplatex -c pdflatex --" --shell-escape -pdf -interaction=nonstopmode "${mainFile}" 2>&1 | tee latexmk_log.txt
    '';

    installPhase = ''
      mkdir $out
      mv "./$(basename ${mainFile} .tex).pdf" $out/
    '';

    doCheck = true;
    checkPhase = ''
      function build_error() {
        echo "=====> There have been warnings or errors in the last run, fix them!"
        exit 1
      }

      cat latexmk_log.txt | grep "o) Errors:" | tail -1 | grep "o) Errors: 0, Warnings: 0" || build_error
    '';
  }
