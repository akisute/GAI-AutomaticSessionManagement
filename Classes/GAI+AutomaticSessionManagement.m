//
//  GAI+AutomaticSessionManagement.m
//  GoogleAnalytics3+AutomaticSessionManagement
//
//  Created by Ono Masashi on 2014/02/06.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import <objc/runtime.h>
#import "GAI+AutomaticSessionManagement.h"
#import "GAIFields.h"

@interface GAIASMTracker ()
@property (nonatomic) id<GAITracker> originalTracker;
@property (nonatomic) NSMutableDictionary *nextDictionary;
@end

@implementation GAIASMTracker

- (instancetype)initWithTracker:(id<GAITracker>)tracker
{
    if (tracker == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.originalTracker = tracker;
        self.nextDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)getNext:(NSString *)parameterName
{
    return self.nextDictionary[parameterName];
}

- (void)setNext:(NSString *)parameterName value:(NSString *)value
{
    self.nextDictionary[parameterName] = value;
}

- (NSString *)name
{
    return self.originalTracker.name;
}

- (BOOL)allowIDFACollection
{
    return self.originalTracker.allowIDFACollection;
}

- (void)setAllowIDFACollection:(BOOL)allowIDFACollection
{
    self.originalTracker.allowIDFACollection = allowIDFACollection;
}

- (void)set:(NSString *)parameterName value:(NSString *)value
{
    [self.originalTracker set:parameterName value:value];
}

- (NSString *)get:(NSString *)parameterName
{
    return [self.originalTracker get:parameterName];
}

- (void)send:(NSDictionary *)parameters
{
    NSMutableDictionary *modifiedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [modifiedParameters addEntriesFromDictionary:self.nextDictionary];
    [self.originalTracker send:modifiedParameters];
    [self.nextDictionary removeAllObjects];
}

@end

#pragma mark -

#define kASMDefaultSessionTimeout 30.0

static NSString *ASMPropertyKey_sessionTimeout = @"ASMPropertyKey_sessionTimeout";
static NSString *ASMPropertyKey_latestDidEnterBackgroundDate = @"ASMPropertyKey_latestDidEnterBackgroundDate";
static NSString *ASMPropertyKey_tracker = @"ASMPropertyKey_tracker";

@implementation GAI (AutomaticSessionManagement)

- (NSTimeInterval)ASM_sessionTimeout
{
    NSNumber *n = objc_getAssociatedObject(self, (__bridge const void *)(ASMPropertyKey_sessionTimeout));
    return (n) ? [n doubleValue] : kASMDefaultSessionTimeout;
}

- (void)setASM_sessionTimeout:(NSTimeInterval)sessionTimeout
{
    objc_setAssociatedObject(self, (__bridge const void *)(ASMPropertyKey_sessionTimeout), @(sessionTimeout), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)ASM_latestDidEnterBackgroundDate
{
    return objc_getAssociatedObject(self, (__bridge const void *)(ASMPropertyKey_latestDidEnterBackgroundDate));
}

- (void)setASM_latestDidEnterBackgroundDate:(NSDate *)date
{
    objc_setAssociatedObject(self, (__bridge const void *)(ASMPropertyKey_latestDidEnterBackgroundDate), date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// ASM_tracker must be retained by this class since defaultTracker property doesn't retain
// So here we declare private property implementations
- (void)setASM_tracker:(GAIASMTracker *)tracker
{
    objc_setAssociatedObject(self, (__bridge const void *)(ASMPropertyKey_tracker), tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ASM_setDefaultTracker:(id<GAITracker>)defaultTracker
{
    GAIASMTracker *asmTracker;
    if ([defaultTracker isKindOfClass:[GAIASMTracker class]]) {
        asmTracker = defaultTracker;
    } else {
        asmTracker = [[GAIASMTracker alloc] initWithTracker:defaultTracker];
    }
    [self setDefaultTracker:asmTracker];
    [self setASM_tracker:asmTracker];
}

- (void)ASM_setNextTrackingAsSessionStart
{
    if ([self.defaultTracker isKindOfClass:[GAIASMTracker class]]) {
        GAIASMTracker *asmTracker = self.defaultTracker;
        [asmTracker setNext:kGAISessionControl value:@"start"];
    }
}

- (void)ASM_setNextTrackingAsSessionEnd
{
    if ([self.defaultTracker isKindOfClass:[GAIASMTracker class]]) {
        GAIASMTracker *asmTracker = self.defaultTracker;
        [asmTracker setNext:kGAISessionControl value:@"end"];
    }
}

- (void)ASM_startAutomaticSessionManagement
{
    NSAssert(self.defaultTracker != nil, @"[GAI defaultTracker] must be set by using ASM_setDefaultTracker before enabling Automatic Session Management.");
    NSAssert([self.defaultTracker isKindOfClass:[GAIASMTracker class]], @"[GAI defaultTracker] must be set by using ASM_setDefaultTracker before enabling Automatic Session Management.");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ASM_onUIApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ASM_onUIApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self ASM_setNextTrackingAsSessionStart];
}

- (void)ASM_onUIApplicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self setASM_latestDidEnterBackgroundDate:[NSDate date]];
}

- (void)ASM_onUIApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    NSTimeInterval delta = (self.ASM_sessionTimeout < 0.01) ? kASMDefaultSessionTimeout : self.ASM_sessionTimeout;
    NSDate *currentDate = [NSDate date];
    NSDate *expireDate = ([self ASM_latestDidEnterBackgroundDate] == nil) ? [NSDate distantPast] : [NSDate dateWithTimeInterval:delta sinceDate:[self ASM_latestDidEnterBackgroundDate]];
    if ([[currentDate earlierDate:expireDate] isEqualToDate:expireDate]) {
        [self ASM_setNextTrackingAsSessionStart];
    }
    [self setASM_latestDidEnterBackgroundDate:nil];
}

@end