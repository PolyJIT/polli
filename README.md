# PolyJIT - Polyhedral JIT compilation

PolyJIT provides polyhedral compilation techniques at run-time of
a program. By exploiting run-time information that is not available at
compile-time some constraints due to the linear nature of the polyhedral
model can be relaxed or ignored all-together, e.g. non-linear parameters in
array-subscript expressions or may-aliases.

PolyJIT is implemented in 2 stages. The first stage selects suitable targets
for just-in-time compilation (LLVMPolyJIT). This can be integrated into
clang just as any other clang compiler plugin. The selected JIT candidates
are instrumented with library calls that let us enter the JIT environment
on demand.

The second stage (libPolyJIT) is a runtime module that needs to be linked
to instrumented binaries. It provides the JIT itself and becomes active
as soon as one of the selected candidates gets called the first time.

* [PolyJIT](http://www.infosun.fim.uni-passau.de/cl/PolyJIT/)

PolyJIT relies on the work of the following projects:

* [Polly](http://polly.llvm.org)
* [LLVM](http://llvm.org)
* [Likwid](https://code.google.com/p/likwid)
* [PAPI](http://icl.cs.utk.edu/papi/)
* [cppformat](https://github.com/cppformat/cppformat)
* [spdlog](https://github.com/gabime/spdlog)
* [libpqxx](http://pqxx.org/development/libpqxx/)

## Installation

It is easiest to use the ```pprof build``` command included with
simbuerg/pprof-study. More details follow.

```
```

## LLVMPolyJIT components

The following sections describe the components available in the static
clang/llvm compiler plugin.

### Configuration options
```
TODO
```

### JIT ScopDetection
```
TODO
```

### SCoP extraction
```
TODO
```

### JIT instrumentation
```
TODO
```

### PAPI instrumentation
```
TODO
```

## libPolyJIT components

The following sections describe the components available in the run-time
library.

### Configuration options

### Function variant generation
```
TODO
```
