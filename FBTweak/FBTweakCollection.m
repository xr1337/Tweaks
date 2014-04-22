/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweak.h"

@implementation FBTweakCollection {
  NSMutableArray *_orderedTweaks;
  NSMutableDictionary *_identifierTweaks;
}

- (instancetype)initWithName:(NSString *)name
{
  if ((self = [super init])) {
    _name = [name copy];
    
    _orderedTweaks = [[NSMutableArray alloc] initWithCapacity:4];
    _identifierTweaks = [[NSMutableDictionary alloc] initWithCapacity:4];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _name = [decoder decodeObjectForKey:@"name"];
        _orderedTweaks = [decoder decodeObjectForKey:@"orderedTweaks"];
        _identifierTweaks = [decoder decodeObjectForKey:@"identifierTweaks"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_orderedTweaks forKey:@"orderedTweaks"];
    [encoder encodeObject:_identifierTweaks forKey:@"identifierTweaks"];
}

- (FBTweak *)tweakWithIdentifier:(NSString *)identifier
{
  return _identifierTweaks[identifier];
}

- (NSArray *)tweaks
{
  return [_orderedTweaks copy];
}

- (void)addTweak:(FBTweak *)tweak
{
  [_orderedTweaks addObject:tweak];
  [_identifierTweaks setObject:tweak forKey:tweak.identifier];
}

- (void)removeTweak:(FBTweak *)tweak
{
  [_orderedTweaks removeObject:tweak];
  [_identifierTweaks removeObjectForKey:tweak.identifier];
}

@end
