#define DEBUG_TYPE "polyjit"
#include "llvm/Support/Debug.h"

#include "polli/AliasCheckCodeGen.h"
#include "polli/Utils.h"

#include "llvm/Pass.h"
#include "llvm/PassSupport.h"
#include "llvm/IR/Instructions.h"

#include "polly/ScopDetection.h"
#include "polly/ScopDetectionDiagnostic.h"
#include "polly/ScopInfo.h"
#include "polly/ScopPass.h"

#include "isl/Format.h"
#include "isl/DimType.h"

#include "isl/Set.hpp"
#include "isl/Map.hpp"
#include "isl/PwAff.hpp"

#include "isl/Printer.hpp"
#include "isl/AstExpr.hpp"
#include "isl/AstBuild.hpp"
#include "isl/Id.hpp"
#include "isl/Space.hpp"

using namespace llvm;
using namespace polli;
using namespace polly;

char AliasCheckGenerator::ID = 0;
static RegisterPass<AliasCheckGenerator>
AliasCheckGenPass("polli-codegen-aliascheck",
                  "Polli - Create run-time alias checks");

AliasCheckGenerator::AliasCheckGenerator()
    : ScopPass(ID), ScopDetectionExtension() {}

void AliasCheckGenerator::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<ScopDetection>();
  AU.addRequired<ScopInfo>();
  AU.setPreservesAll();
}

using namespace isl;
Set AliasCheckGenerator::checkPairs(const Set &Cond, const Set &Acc,
                                    const BoundsMapT &map) const {
  Set AccA = Acc;
  Set ResCond = Cond;

  // Eliminate all but one single dimension and take the min/max.
  unsigned int ndims = AccA.dim(DimType::DTSet);
  AccA = AccA.eliminate(DimType::DTSet, 1, ndims - 1);
  PwAff minA = AccA.dimMin(0);
  PwAff maxA = AccA.dimMax(0);

  Space spaceA = AccA.getSpace();
  std::string nA = spaceA.getTupleName(DimType::DTSet);
  Set baseA = Set::readFromStr("[" + nA + "] -> { [" + nA + "] };");
  PwAff bpA = baseA.dimMin(0);

  minA = minA.add(bpA);
  maxA = maxA.add(bpA);

  for (const isl::Set &s : map) {
    Set AccB = s;

    ndims = AccB.dim(DimType::DTSet);
    AccB = AccB.eliminate(DimType::DTSet, 1, ndims - 1);

    Space spaceB = AccB.getSpace();
    std::string nB = spaceB.getTupleName(DimType::DTSet);
    Set baseB = Set::readFromStr("[" + nB + "] -> { [" + nB + "] };");
    PwAff bpB = baseB.dimMin(0);

    PwAff minB = AccB.dimMin(0).add(bpB);
    PwAff maxB = AccB.dimMax(0).add(bpB);

    ResCond = ResCond.intersect(minA.leSet(maxB).intersect(minB.leSet(maxA)));
    ResCond = ResCond.coalesce();
  }
  return ResCond;
}

void AliasCheckGenerator::printConditions(const isl::Set &ParamContext,
                                          const isl::Set &Acc,
                                          const BoundsMapT &map) const {
  void *np = NULL;
  Set AccA = Acc;

  // Eliminate all but one single dimension and take the min/max.
  unsigned int ndims = AccA.dim(DimType::DTSet);
  AccA = AccA.eliminate(DimType::DTSet, 1, ndims - 1);
  PwAff minA = AccA.dimMin(0);
  PwAff maxA = AccA.dimMax(0);

  AstBuild Builder = AstBuild::fromContext(ParamContext);
  Space A = AccA.getSpace();
  std::string nA = A.getTupleName(DimType::DTSet);
  Id idA = Id::alloc(nA, np);

  AstExpr ExpMinA = Builder.exprFromPwAff(minA);
  AstExpr ExpMaxA = Builder.exprFromPwAff(maxA);
  AstExpr ExpIdA = AstExpr::fromId(idA);

  ExpMinA = ExpIdA.add(ExpMinA);
  ExpMaxA = ExpIdA.add(ExpMaxA);

  for (const isl::Set &s : map) {
    Set AccB = s;
    Space B = AccB.getSpace();

    std::string nB = B.getTupleName(DimType::DTSet);
    Id idB = Id::alloc(nB, np);

    PwAff minB = AccB.dimMin(0);
    PwAff maxB = AccB.dimMax(0);

    AstExpr ExpMinB = Builder.exprFromPwAff(minB);
    AstExpr ExpMaxB = Builder.exprFromPwAff(maxB);
    AstExpr ExpIdB = AstExpr::fromId(idB);

    ExpMinB = ExpIdB.add(ExpMinB);
    ExpMaxB = ExpIdB.add(ExpMaxB);

    dbgs().indent(6) << "[ (" << ExpMinA.toStr(Format::FC) << ")";
    dbgs() << " <=  (" << ExpMaxB.toStr(Format::FC) << ")";
    dbgs() << " && (" << ExpMinB.toStr(Format::FC) << ")";
    dbgs() << " <=  (" << ExpMaxA.toStr(Format::FC) << ") ]\n";
  }
}

template <class T = unsigned long>
static T binomial_coefficient(unsigned long n, unsigned long k) {
  unsigned long i;
  T b;
  if (0 == k || n == k) {
    return 1;
  }
  if (k > n) {
    return 0;
  }
  if (k > (n - k)) {
    k = n - k;
  }
  if (1 == k) {
    return n;
  }
  b = 1;
  for (i = 1; i <= k; ++i) {
    b *= (n - (k - i));
    if (b < 0)
      return -1; /* Overflow */
    b /= i;
  }
  return b;
}

void AliasCheckGenerator::printIslExpressions(const Scop &S) {
  BoundsMapT BoundsMap;
  unsigned int numAccs = 0;
  for (ScopStmt *Stmt : S) {
    for (MemoryAccess *Acc : *Stmt) {
      Map Access = isl::Map(Acc->getAccessRelation());
      Set Domain = isl::Set(Stmt->getDomain());
      const Set MemAccs = Domain.apply(Access);
      if (!BoundsMap.count(MemAccs)) {
        BoundsMap.insert(MemAccs);
        ++numAccs;
      }
    }
  }

  log(Debug, 2) << "Num Accesses: " << numAccs << " -> "
                << binomial_coefficient(numAccs, 2) << "\n";

  BoundsMapT mapcp = BoundsMap;
  const Set ParamCtx = Set(S.getAssumedContext());
  Set Cond = Set::universe(ParamCtx.getSpace());

  for (const Set &s : BoundsMap) {
    BoundsMapT::iterator it = mapcp.find(s);
    if (it != mapcp.end()) {
      mapcp.erase(it);
      if (mapcp.size() > 0) {
        Cond = checkPairs(Cond, s, mapcp);
      }
    }
  }

  AstBuild Builder = AstBuild::fromContext(ParamCtx);
  PwAff Check = Cond.indicatorFunction();
  AstExpr ExprCheck = Builder.exprFromPwAff(Check);

  log(Debug, 4) << "if (" << ExprCheck.toStr(Format::FC) << ")\n\n";
}

bool AliasCheckGenerator::runOnScop(Scop &S) {
  SD = &getAnalysis<ScopDetection>();
  Region &ScopRegion = S.getRegion();

  for (ScopDetection::reject_iterator RI = SD->reject_begin(),
                                      RE = SD->reject_end();
       RI != RE; ++RI) {
    const Region *R = RI->first;
    RejectLog &Log = RI->second;

    // for (RejectReasonPtr RRPtr : Log) {
    //  if (ReportAlias *AliasError = dyn_cast<ReportAlias>(RRPtr.get())) {
    //    if (R == &ScopRegion)
    //  }
    //}
  }
  return true;
}
