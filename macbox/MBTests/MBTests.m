//
//  MacboxTests.m
//  MacboxTests
//
//  Created by Mark on 27/11/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SafeMetaData.h"

@interface MBTests : XCTestCase

@end

@implementation MBTests

- (void)testExampleTouchIdPassword {
    SafeMetaData *metadata = [[SafeMetaData alloc] initWithNickName:@"Unit Testing" storageProvider:kLocalDevice fileName:@"yo" fileIdentifier:@"unit test"];
    
    metadata.touchIdPassword = @"Testing!";
    
    NSLog(@"%@", metadata.touchIdPassword);
}

- (void)testEmptyTouchIdPassword {
    SafeMetaData *metadata = [[SafeMetaData alloc] initWithNickName:@"Unit Testing" storageProvider:kLocalDevice fileName:@"yo" fileIdentifier:@"unit test"];
    
    metadata.touchIdPassword = @"";
    
    NSLog(@"%@", metadata.touchIdPassword);
    
    XCTAssertNotNil(metadata.touchIdPassword);
}

- (void)testNilTouchIdPassword {
    SafeMetaData *metadata = [[SafeMetaData alloc] initWithNickName:@"Unit Testing" storageProvider:kLocalDevice fileName:@"yo" fileIdentifier:@"unit test"];
    
    metadata.touchIdPassword = nil;
    
    NSLog(@"%@", metadata.touchIdPassword);
    
    XCTAssertNil(metadata.touchIdPassword);
}

@end
