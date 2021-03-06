//
//  BiometricIdHelper.h
//  Macbox
//
//  Created by Mark on 04/04/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BiometricIdHelper : NSObject

+ (instancetype)sharedInstance;

- (void)authorize:(void (^)(BOOL success, NSError *error))completion;
- (void)authorize:(NSString*)fallbackTitle completion:(void (^)(BOOL success, NSError *error))completion;

@property (nonatomic, strong) NSString* biometricIdName;
@property (nonatomic) BOOL biometricIdAvailable;

@property BOOL dummyMode;
@property BOOL biometricsInProgress;

@property (readonly) BOOL isTouchIdUnlockAvailable;
@property (readonly) BOOL isWatchUnlockAvailable;

@end
