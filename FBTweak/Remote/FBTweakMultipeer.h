//
//  FBTweakMultipeer.h
//  FBTweak
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

extern NSString *const kMultipeerServiceName;
extern NSString *const kMultipeerActionKey;
extern NSString *const kMultipeerDataKey;
extern NSString *const kMultipeerTweakKey;

extern NSString *const kMultipeerSetupParameter;
extern NSString *const kMultipeerUpdateParameter;


@interface FBTweakMultipeer : NSObject

+ (instancetype)shareInstance;

- (void)start;

@end
