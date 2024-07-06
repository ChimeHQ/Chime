@import Foundation;

#include <os/base.h>

#ifdef APP_GROUP
NSString* const CHMAppGroupIdentifier = @OS_STRINGIFY(APP_GROUP);
#else
#error Undefined
#endif

#ifdef SHARED_SUITE
NSString* const CHMUserDefaultsSharedSuite = @OS_STRINGIFY(SHARED_SUITE);
#else
#error Undefined
#endif
