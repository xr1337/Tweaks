//
//  FBTweakStore+Protected.m
//  FBTweak
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweakStore+Protected.h"

@interface FBTweakStore()

@property (nonatomic, strong) NSMutableArray *orderedCategories;

@end

@implementation FBTweakStore (Protected)

- (void)setProtectedOrderedCategories:(NSMutableArray *)array
{
    self.orderedCategories = array;
}

@end
