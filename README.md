GAI-AutomaticSessionManagement
==============================

This small library enables automatic session management for Google Analytics (GAI) for iOS version 3. Automatic session management feature is supported in the prior version of GAI for iOS and the latest version of GAI for Android, but somehow only GAI for iOS version 3 doesn't. For more information, refer the following documents:

- GAI for iOS version 3 session management: https://developers.google.com/analytics/devguides/collection/ios/v3/sessions
- GAI for iOS version 2 session management: https://developers.google.com/analytics/devguides/collection/ios/v2/sessions
- GAI for Android version 3 session management: https://developers.google.com/analytics/devguides/collection/android/v3/sessions

How to use
==========

You need to install GAI for iOS 3 SDK to your project before use. Refer the following documentation to learn how to install the SDK:
https://developers.google.com/analytics/devguides/collection/ios/v3/

After you install the SDK,

1. Clone the repository.
2. Copy all files under `Classes` folder to your project.

Then all you have to do is:

1. Import `GAI+AutomaticSessionManagement.h`
2. Setup default tracker instance by using `ASM_setDefaultTracker:`
3. Start automatic session managements by calling `ASM_startAutomaticSessionManagement`

That's it. Here's a short example:

```objc
#import "AppDelegate.h"
#import "GAI+AutomaticSessionManagement.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // GAI+AutomaticSessionManagement requires the default tracker to be set before use.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"MY-TRACKING-ID"];
    
    // Make sure to use ASM_setDefaultTracker when setting the default tracker!
    [[GAI sharedInstance] ASM_setDefaultTracker:tracker];
    
    // Begin automatic session management.
    [[GAI sharedInstance] ASM_startAutomaticSessionManagement];
    
    /*... Your Code ...*/
}
```

Note that only sessions tracked by the default tracker will be managed automatically. If you have other trackers, this library won't do anything automatically to those trackers.

Tested under iOS SDK version 7 and Xcode 5.0.2. Runs on iOS 5.0.0 or above.

TODO
====

- Support CocoaPods
- (Possibly) Multiple tracker support, if requested
