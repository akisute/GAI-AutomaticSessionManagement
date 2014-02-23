//
//  GAI+AutomaticSessionManagement.h
//  GoogleAnalytics3+AutomaticSessionManagement
//
//  Created by Ono Masashi on 2014/02/06.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

/**
 This addition will enable automatic session management feature, which is removed from SDK in version 3 for unknown reasons :(
 
 For more information, refer following documentations.
 
 Google Analytics iOS SDK v2 Session Management documentation: https://developers.google.com/analytics/devguides/collection/ios/v2/sessions
 Google Analytics iOS SDK v3 Session Management documentation: https://developers.google.com/analytics/devguides/collection/ios/v3/sessions
 
 Implementation:
 GAI+AutomaticSessionManagement wraps `[[GAI sharedInstance] defaultTracker]` with custom implementation
 to send session start control parameter in addition to the original given parameters for tracker.
 
 GAI+AutomaticSessionManagement also watches for application lifecycle and adds session control parameters automatically
 according to the previous specifications of Google Analytics iOS SDK v2.
 */

@interface GAIASMTracker : NSObject<GAITracker>

- (instancetype)initWithTracker:(id<GAITracker>)tracker;

- (NSString *)getNext:(NSString *)parameterName;
- (void)setNext:(NSString *)parameterName value:(NSString *)value;

@end

#pragma mark -

@interface GAI (AutomaticSessionManagement)

@property (nonatomic) NSTimeInterval ASM_sessionTimeout;
@property (nonatomic) NSDate *ASM_latestDidEnterBackgroundDate;

- (void)ASM_setDefaultTracker:(id<GAITracker>)defaultTracker;
- (void)ASM_setNextTrackingAsSessionStart;
- (void)ASM_setNextTrackingAsSessionEnd;
- (void)ASM_startAutomaticSessionManagement;

@end