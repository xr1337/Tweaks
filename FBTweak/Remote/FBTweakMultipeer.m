//
//  FBTweakMultipeer.m
//  FBTweak
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweakMultipeer.h"

#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "FBTweak.h"

static NSString *const kServiceName = @"xx-service";

@interface FBTweakMultipeer () <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *localPeerId;
@property (nonatomic, strong) MCPeerID *remotePeerId;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property (nonatomic, strong) FBTweakStore *tweakStore;

@end

@implementation FBTweakMultipeer

+ (instancetype)shareInstance
{
    static FBTweakMultipeer *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[FBTweakMultipeer alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tweakStore = [FBTweakStore sharedInstance];
        
        [self setupPeerWithDisplayName:[UIDevice currentDevice].name];
        [self setupSession];
    }
    return self;
}

- (void)start
{
    [self advertiseSelf:YES];
}

- (void)stop
{
    NSAssert(NO, @"not implemented yet");
}

#pragma mark - setup

- (void)setupPeerWithDisplayName:(NSString *)displayName
{
    self.localPeerId = [[MCPeerID alloc] initWithDisplayName:displayName];
}

- (void)setupSession
{
    self.session = [[MCSession alloc] initWithPeer:self.localPeerId];
    self.session.delegate = self;
}

- (void)advertiseSelf:(BOOL)advertise
{
    if (advertise)
    {
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceName discoveryInfo:nil session:self.session];
        [self.advertiser start];
    }
    else
    {
        [self.advertiser stop];
        self.advertiser = nil;
    }
}

#pragma mark - multipeer



- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected)
    {
        self.remotePeerId = peerID;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    [self handleData:data fromPeer:peerID];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSAssert(NO, @"not supported yet");
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSAssert(NO, @"not supported yet");
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSAssert(NO, @"not supported yet");
}

- (void)handleData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([dataDictionary[@"action"] isEqualToString:@"setup"])
    {
        NSError *error = nil;
        
        NSDictionary *dictionary = @{
                                     @"action" : @"setup",
                                     @"data" : [_tweakStore tweakCategories],
                                     };
        
        NSData *responseData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        [self.session sendData:responseData toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
        if (error)
        {
            NSLog(@"data failed to be sent");
        }
        return;
    }
    if ([dataDictionary[@"action"] isEqualToString:@"update"])
    {
        FBTweak *tweak = dataDictionary[@"tweak"];
        FBTweak *localTweak = [[[_tweakStore tweakCategoryWithName:tweak.categoryName] tweakCollectionWithName:tweak.collectionName] tweakWithIdentifier:tweak.identifier];
        localTweak.currentValue = [tweak.currentValue copy];
        return;
    }
}

@end
