# polli - PolyJIT's JIT compiler

polli is a polyhedral JIT compiler. It enhances LLVM's Polly plugin by
providing additional run-time information for Polly's SCoP detection
process to increase the number of valid SCoPs in a program.

polli is derived from LLVM's lli implementation and provides similar
flags and options to control the first code generation stage.

## Build

  TODO.

## Usage

 * Polli Options:
   - -L=<directory>
     Specify a library search path
   - -caddy
     Enable Caddy (Requires a special build of Polly).
   - -instrument
     Enable instrumenting of SCoPs
   - -jitable
     Enable Non AffineSCoPs. Requires at least -polly-detect-track-failures.
   - -l=<library prefix>
     Specify libraries to link to. polli will load the library into its own address
     space.
   - -no-execution
     Disable execution just produce all intermediate files.
   - -no-recompilation
     Disable recompilation of SCoPs.
   - -tempdir
     Place temporary files into unique subdir
