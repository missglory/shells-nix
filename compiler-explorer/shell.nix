# shell.nix

{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) fetchFromGitHub;
  compilerExplorerSrc = fetchFromGitHub {
    owner = "mattgodbolt";
    repo = "compiler-explorer";
    rev = "v5.2.0";
    sha256 = "0ix3zx0dwqny4f1c2xw6z65avjg0ddrxn3k9g48l0fxsnk9z2hm9";
  };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs
    pkgs.git
    pkgs.cmake
    pkgs.llvmPackages.libclang
    pkgs.clang
  ];
  shellHook = ''
    export COMPILER_EXPLORER_DIR="$PWD/compiler-explorer"
    export COMPILER_EXPLORER_CONFIG="$COMPILER_EXPLORER_DIR/etc/config"
    export COMPILER_EXPLORER_STATIC_DIR="$COMPILER_EXPLORER_DIR/static"
    export COMPILER_EXPLORER_LIB_DIR="$COMPILER_EXPLORER_DIR/lib"
    export COMPILER_EXPLORER_BUILDDIR="$COMPILER_EXPLORER_DIR/build"
    export PATH=$COMPILER_EXPLORER_DIR/node_modules/.bin:$PATH

    # Clone Compiler Explorer repository
    git clone https://github.com/mattgodbolt/compiler-explorer.git "$COMPILER_EXPLORER_DIR"

    # Install Compiler Explorer dependencies
    cd "$COMPILER_EXPLORER_DIR"
    npm install

    # Set up Compiler Explorer configuration for Chromium
    cp "$COMPILER_EXPLORER_DIR/etc/config/clang-9.0.0-cxx17.js" "$COMPILER_EXPLORER_CONFIG"
    echo "baseDir: '$PWD'" >> "$COMPILER_EXPLORER_CONFIG"

    # Build Compiler Explorer
    cd "$COMPILER_EXPLORER_BUILDDIR"
    cmake -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release ..
    make

    echo "To start Compiler Explorer, run 'make run' in the '$COMPILER_EXPLORER_BUILDDIR' directory."
  '';
}

