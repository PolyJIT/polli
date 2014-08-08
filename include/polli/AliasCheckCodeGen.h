#ifndef POLLI_ALIASCHECKCODEGEN_H
#define POLLI_ALIASCHECKCODEGEN_H

#include "polly/ScopDetection.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/ScopInfo.h"
#include "polly/ScopPass.h"

#include "isl++/Set.h"
#include "isl++/Map.h"
#include "isl++/PwAff.h"

namespace polli {
class AliasCheckGenerator : public polly::ScopPass,
                            public polly::ScopDetectionExtension {
private:
  polly::ScopDetection *SD;

public:
  static char ID;

  explicit AliasCheckGenerator();
  virtual ~AliasCheckGenerator() {}

  bool isFixable(polly::ReportAlias &) override { return true; }

  typedef std::set<isl::Set> BoundsMapT;

  void getAnalysisUsage(AnalysisUsage &AU) const;
  void printIslExpressions(const polly::Scop &S);
  void checkPairs(const isl::Set &ParamContext, const isl::Set &Acc,
                  const BoundsMapT &map) const;
  void printConditions(const isl::Set &ParamContext, const isl::Set &Acc,
                       const BoundsMapT &map) const;

  bool runOnScop(polly::Scop &S) override;
};
}

#endif // POLLI_ALIASCHECKCODEGEN_H
