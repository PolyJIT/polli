LEVEL := ..
MODULES := libpprof.o

include $(LEVEL)/Makefile.config

CFLAGS += -O3
CFLAGS += -I./include
CFLAGS += $(PAPI_CFLAGS)

%.o: %.cpp
	$(VERB)clang++ -g -std=c++11 -fPIC -O0 -o $@ $^ $(CFLAGS) -c

libpprof.so: $(MODULES)
	$(VERB)clang++ -g -shared -std=c++11 -rdynamic $(CFLAGS) \
	  -o $@ $(PAPI_CFLAGS) $(PAPI_LDFLAGS) $(LDFLAGS) $^

calibrate::
	$(VERB)clang++ -DENABLE_CALIBRATION -std=c++11 -rdynamic $(CFLAGS) \
	  $(PAPI_CFLAGS) $(PAPI_LDFLAGS) $(LDFLAGS) \
	  -o $@ libpprof.cpp

pprof::
	clang++ -std=c++11 -rdynamic -O0 -g  \
	  $(PAPI_CFLAGS) $(PAPI_LDFLAGS) $(LDFLAGS) -o $@ pprof.cpp

clean::
	$(VERB)rm -f $(MODULES)
	$(VERB)rm -f libpprof.so
