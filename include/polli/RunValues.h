/* RunValue extraction for the PolyJIT Compiler
 * Copyright © 2016 Andreas Simbürger <simbuerg@lairosiel.de>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#ifndef POLLI_RUNVALUES_H
#define POLLI_RUNVALUES_H

#include "polli/RuntimeValues.h"
#include <cassert>
#include <memory>
#include <cstring>
#include <array>

namespace llvm {
class Function;
}

namespace polli {
struct SpecializerRequest {
  const char *IR;
  unsigned ParamC;
  void *Params;
  llvm::Function *F{nullptr};

  SpecializerRequest(const char *IR, unsigned ParamC, char **params)
      : IR(IR), ParamC(ParamC) {
        size_t n = ParamC * sizeof(void *);
        Params = std::malloc(n);
        std::memcpy(Params, params, n);
      }

  ~SpecializerRequest() {
    std::free(Params);
  }
};

using JitRequestT = std::shared_ptr<SpecializerRequest>;
RunValueList runValues(const SpecializerRequest &Request);
#ifndef NDEBUG
void printArgs(const llvm::Function &F, size_t argc, void *params);
void printRunValues(const RunValueList &Values);
#endif
}
#endif /* end of include guard: POLLI_RUNVALUES_H */
