/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"

NSString *const kTweakValueChangedNotification = @"kTweakValueChangedNotification";

@implementation FBTweak {
  NSHashTable *_observers;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
  if ((self = [super init])) {
    _identifier = identifier;
    _currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:_identifier];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _identifier = [decoder decodeObjectForKey:@"identifier"];
        _name = [decoder decodeObjectForKey:@"name"];
        _defaultValue = [decoder decodeObjectForKey:@"defaultValue"];
        _currentValue = [decoder decodeObjectForKey:@"currentValue"];
        _minimumValue = [decoder decodeObjectForKey:@"minimumValue"];
        _maximumValue = [decoder decodeObjectForKey:@"maximumValue"];
        _categoryName = [decoder decodeObjectForKey:@"categoryName"];
        _collectionName = [decoder decodeObjectForKey:@"collectionName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_defaultValue forKey:@"defaultValue"];
    [encoder encodeObject:_currentValue forKey:@"currentValue"];
    [encoder encodeObject:_minimumValue forKey:@"minimumValue"];
    [encoder encodeObject:_maximumValue forKey:@"maximumValue"];
    [encoder encodeObject:_categoryName forKey:@"categoryName"];
    [encoder encodeObject:_collectionName forKey:@"collectionName"];
}

- (BOOL)isAction
{
  // NSBlock isn't a public class, walk the hierarchy for it.
  Class blockClass = [^{} class];

  while ([blockClass superclass] != [NSObject class]) {
    blockClass = [blockClass superclass];
  }

  return [_defaultValue isKindOfClass:blockClass];
}

- (void)setCurrentValue:(FBTweakValue)currentValue
{
  NSAssert(!self.isAction, @"actions cannot have non-default values");

  if (_minimumValue != nil && currentValue != nil && [_minimumValue compare:currentValue] == NSOrderedDescending) {
    currentValue = _minimumValue;
  }
  
  if (_maximumValue != nil && currentValue != nil && [_maximumValue compare:currentValue] == NSOrderedAscending) {
    currentValue = _maximumValue;
  }
  
  if (_currentValue != currentValue) {
    _currentValue = currentValue;
    [[NSUserDefaults standardUserDefaults] setObject:_currentValue forKey:_identifier];
    
    for (id<FBTweakObserver> observer in [_observers setRepresentation]) {
      [observer tweakDidChange:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTweakValueChangedNotification object:self];
  }
}

- (void)addObserver:(id<FBTweakObserver>)observer
{
  if (_observers == nil) {
    _observers = [NSHashTable weakObjectsHashTable];
  }
  
  NSAssert(observer != nil, @"observer is required");
  [_observers addObject:observer];
}

- (void)removeObserver:(id<FBTweakObserver>)observer
{
  NSAssert(observer != nil, @"observer is required");
  [_observers removeObject:observer];
}

@end
