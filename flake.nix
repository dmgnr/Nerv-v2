{
  description = "Nerv compiler and standard library";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_23.llvm;
          llvmConfig = "${pkgs.llvmPackages_23.llvm.dev}/bin/llvm-config";
        in {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = "nerv";
            version = "1.0.0";
            src = self;
            cargoLock.lockFile = ./Cargo.lock;
            cargoBuildFlags = [ "-p" "nerv" ];
            cargoTestFlags = [ "-p" "nerv" ];
            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ llvm llvm.dev pkgs.libxml2 ];
            LLVM_SYS_231_PREFIX = "${llvm.dev}";
            LLVM_CONFIG_PATH = llvmConfig;
            doCheck = false;
            meta = {
              description = "The Nerv programming language compiler";
              homepage = "https://github.com/NPSummers/Nerv-v2";
              license = pkgs.lib.licenses.mit;
              mainProgram = "nerv";
              platforms = systems;
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_23.llvm;
          llvmConfig = "${pkgs.llvmPackages_23.llvm.dev}/bin/llvm-config";
        in {
          default = pkgs.mkShell {
            packages = [ pkgs.cargo pkgs.rustc pkgs.pkg-config llvm ];
            LLVM_SYS_231_PREFIX = "${llvm.dev}";
            LLVM_CONFIG_PATH = llvmConfig;
          };
        });
    };
}
