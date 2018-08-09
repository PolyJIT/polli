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

#include <array>
#include <cassert>
#include <cstring>
#include <iostream>
#include <memory>

#include "absl/strings/string_view.h"
#include "absl/types/optional.h"
#include "absl/types/variant.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

#include "polli/RuntimeValues.h"

using llvm::Function;
using llvm::Module;

namespace polli {
using VarParam = absl::variant<uint64_t, void *>;
struct JitRequest {
  size_t Hash;
  std::shared_ptr<const Module> M;
  llvm::SmallVector<void *, 4> Params;
};

struct VariantRequest {
  size_t Hash;
  absl::optional<const Function *> F;
  llvm::SmallVector<VarParam, 4> Params;
};

JitRequest make_request(const absl::string_view FnName,
                        std::shared_ptr<const Module> M,
                        llvm::SmallVector<void *, 4> Params);

VariantRequest make_variant_request(JitRequest JitReq);

class SpecializerRequest {
private:
  const uint64_t IRKey;
  const unsigned ParamC;
  std::vector<void *> Params;

  std::shared_ptr<const Module> M;
  Function *F;

  Function *init(std::shared_ptr<Module> PrototypeM);

public:
  SpecializerRequest(uint64_t key, unsigned ParamC, void *params,
                     std::shared_ptr<Module> M)
      : IRKey(key), ParamC(ParamC), Params(), M(M), F(init(M)) {
    size_t N = ParamC * sizeof(void *);
    Params.resize(ParamC);
    std::memcpy(Params.data(), params, N);
  }

  size_t paramSize() const { return ParamC; }

  const std::vector<void *> &params() const { return Params; }

  uint64_t key() const { return IRKey; }

  llvm::Function &prototype() const { return *F; }
  std::shared_ptr<const Module> prototypeModule() const { return M; }
};

RunValueList runValues(const SpecializerRequest &Request);
#ifndef NDEBUG
void printArgs(const Function &F, size_t argc,
               const std::vector<void *> &Params);
#endif
void printRunValues(const RunValueList &Values);
} // namespace polli
#endif // POLLI_RUNVALUES_H
