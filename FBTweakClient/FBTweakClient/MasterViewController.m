//
//  MasterViewController.m
//  FBTweakClient
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 XR1337. All rights reserved.
//

#import "MasterViewController.h"
#import <FBTweak/FBTweakStore+Protected.h>
#import <FBTweak/FBTweakViewController.h>
#import <FBTweak/FBTweak.h>

@import MultipeerConnectivity;

static NSString * const XXServiceType = @"xx-service";

@interface MasterViewController ()<MCBrowserViewControllerDelegate, MCSessionDelegate, FBTweakViewControllerDelegate> {
    NSMutableArray *_objects;
}

@property (nonatomic, strong)MCSession *session;
@property (nonatomic, strong)MCPeerID *localPeerID;
@property (nonatomic, strong)MCNearbyServiceBrowser *browser;

@property (nonatomic, strong)MCPeerID *remotePeerID;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(findAdvertiser)];
    self.navigationItem.rightBarButtonItem = addButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendUpdates:) name:kTweakValueChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - peer discovery

- (void)findAdvertiser
{
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:XXServiceType];
    self.session = [[MCSession alloc] initWithPeer:_localPeerID
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    MCBrowserViewController *browserViewController =
    [[MCBrowserViewController alloc] initWithBrowser:self.browser
                                             session:self.session];
    browserViewController.delegate = self;
    
    [self presentViewController:browserViewController
                                      animated:YES
                                    completion:
     ^{
         [self.browser startBrowsingForPeers];
     }];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [self requestSetup];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected)
    {
        self.remotePeerID = peerID;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(![dataDictionary isKindOfClass:[NSDictionary class]])
    {
        NSAssert(NO, @"Unsupported dat type");
        return;
    }
    [self handleData:dataDictionary];
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController
{
    [tweakViewController dismissViewControllerAnimated:YES completion:^{
        [self.session disconnect];
    }];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSAssert(NO, @"Not yet supported");
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSAssert(NO, @"Not yet supported");
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSAssert(NO, @"Not yet supported");
}

- (void)handleData:(NSDictionary *)data
{
    if([data[@"action"] isEqualToString:@"setup"])
    {
        NSMutableArray *array = data[@"data"];
        FBTweakStore *store = [FBTweakStore sharedInstance];
        [store setProtectedOrderedCategories:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:store];
            viewController.tweaksDelegate = self;
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
        });
    }
}

- (void)requestSetup
{
    NSDictionary *dictionary = @{
                                 @"action" : @"setup",
                                 };
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSError *error;
    [self.session sendData:data toPeers:@[self.remotePeerID] withMode:MCSessionSendDataReliable error:&error];
    if (!error)
    {
        NSLog(@"%@",[error description]);
    }
}

- (void)sendUpdates:(NSNotification *)notificationObject
{
    NSLog(@"sending data");
    FBTweak *tweak = [notificationObject object];
    NSDictionary *dictionary = @{
                                 @"action" : @"update",
                                 @"tweak" : tweak,
                                 };
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSError *error;
    [self.session sendData:data toPeers:@[self.remotePeerID] withMode:MCSessionSendDataReliable error:&error];
    if (!error)
    {
        NSLog(@"%@",[error description]);
    }
}

@end
