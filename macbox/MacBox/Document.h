//
//  Document.h
//  MacBox
//
//  Created by Mark on 01/08/2017.
//  Copyright © 2017 Mark McGuill. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractDatabaseFormatAdaptor.h"
#import "CompositeKeyFactors.h"
#import "DatabaseMetadata.h"
#import "ViewModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kModelUpdateNotificationLongRunningOperationStart; 
extern NSString* const kModelUpdateNotificationLongRunningOperationDone;
extern NSString* const kModelUpdateNotificationFullReload;
extern NSString* const kModelUpdateNotificationDatabaseChangedByOther;
extern NSString* const kModelUpdateNotificationBackgroundSyncDone;

extern NSString* const kNotificationUserInfoParamKey;

extern NSString* const kNotificationUserInfoLongRunningOperationStatus;
@interface Document : NSDocument

@property (readonly) ViewModel* viewModel;
@property (readonly, nullable) DatabaseMetadata* databaseMetadata;

- (instancetype)initWithCredentials:(DatabaseFormat)format compositeKeyFactors:(CompositeKeyFactors*)compositeKeyFactors;

- (void)revertWithUnlock:(CompositeKeyFactors *)compositeKeyFactors
          viewController:(NSViewController*)viewController
              completion:(void (^)(BOOL success, NSError * _Nullable))completion;

- (void)onSyncChangedUnderlyingWorkingCopy; 

@end

NS_ASSUME_NONNULL_END

