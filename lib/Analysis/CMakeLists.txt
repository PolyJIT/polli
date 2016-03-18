add_library(PolyJIT_Analysis STATIC
	JitScopDetection.cpp
        NonAffineSCEVs.cpp
        ScopDetection.cpp
	ScopDetectionCheckers.cpp		
)
