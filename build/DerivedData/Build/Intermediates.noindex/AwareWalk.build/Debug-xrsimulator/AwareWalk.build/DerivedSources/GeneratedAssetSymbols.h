#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.jingjing.AwareWalk";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "AppIcon/Middle/Content" asset catalog image resource.
static NSString * const ACImageNameAppIconMiddleContent AC_SWIFT_PRIVATE = @"AppIcon/Middle/Content";

/// The "AppIcon/Front/Content" asset catalog image resource.
static NSString * const ACImageNameAppIconFrontContent AC_SWIFT_PRIVATE = @"AppIcon/Front/Content";

/// The "AppIcon/Back/Content" asset catalog image resource.
static NSString * const ACImageNameAppIconBackContent AC_SWIFT_PRIVATE = @"AppIcon/Back/Content";

#undef AC_SWIFT_PRIVATE
