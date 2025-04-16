@import Foundation;

#include <os/base.h>

#ifdef APP_GROUP
NSString* const CHMAppGroupIdentifier = @OS_STRINGIFY(APP_GROUP);
#else
#error Undefined
#endif
