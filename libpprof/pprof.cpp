#include "pprof/pprof.h"

#include <fstream>
#include <sstream>
#include <iostream>
#include <memory>

#include <assert.h>

#include <string>

std::ostream &operator<<(std::ostream &os, const PPEvent &event) {
  return os << event.ID << " " << event.Timestamp << " " << event.EventTy
            << "\n";
}

std::ostream &operator<<(std::ostream &os, const PPEvent *event) {
  return os << event->ID << " " << event->Timestamp << " " << event->EventTy
            << "\n";
}

std::ostream &operator<<(std::ostream &os, const PPStringRegion &R) {
  std::string entStr = R.Entry;
  if (entStr.size() == 0)
    entStr = "ERROR:Entry";
  std::string exStr = R.Exit;
  if (exStr.size() == 0)
    exStr = "ERROR:Exit";

  return os << R.ID << " " << entStr << " " << exStr;
}

std::istream &operator>>(std::istream &is, PPEvent &event) {
  int EventTy;
  is >> event.ID;
  is >> event.Timestamp;
  is >> EventTy;

  event.EventTy = (PPEventType)EventTy;
  return is;
}

std::istream &operator>>(std::istream &is, PPStringRegion &R) {
  is >> R.ID >> R.Entry >> R.Exit;
  return is.ignore(1, '\n');
}
