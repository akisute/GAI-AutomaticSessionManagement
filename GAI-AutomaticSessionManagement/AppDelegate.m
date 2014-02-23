//
//  AppDelegate.m
//  GAI-AutomaticSessionManagement
//
//  Created by Ono Masashi on 2014/02/24.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI+AutomaticSessionManagement.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // GAI+AutomaticSessionManagement requires the default tracker to be set before use.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"MY-TRACKING-ID"];
    
    // Make sure to use ASM_setDefaultTracker to set the default tracker!
    [[GAI sharedInstance] ASM_setDefaultTracker:tracker];
    
    // Begin automatic session management.
    [[GAI sharedInstance] ASM_startAutomaticSessionManagement];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
