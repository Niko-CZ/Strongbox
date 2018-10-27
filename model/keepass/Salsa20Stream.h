//
//  Salsa20Stream.h
//  StrongboxTests
//
//  Created by Mark on 17/10/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InnerRandomStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface Salsa20Stream : NSObject<InnerRandomStream>

-(id)init NS_UNAVAILABLE;
-(id)initWithIv:(const uint8_t*)iv key:(const NSData*)key NS_DESIGNATED_INITIALIZER;
-(NSData *)xor:(NSData *)ct;

+ (nullable NSData*)generateNewKey;

@property (nonatomic, readonly) NSData* key;

@end

NS_ASSUME_NONNULL_END
