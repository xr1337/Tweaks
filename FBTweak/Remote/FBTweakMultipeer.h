//
//  FBTweakMultipeer.h
//  FBTweak
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

@interface FBTweakMultipeer : NSObject

+ (instancetype)shareInstance;

- (void)start;

@end
