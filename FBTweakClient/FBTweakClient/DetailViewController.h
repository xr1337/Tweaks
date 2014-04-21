//
//  DetailViewController.h
//  FBTweakClient
//
//  Created by Sufiyan Yasa on 21/04/14.
//  Copyright (c) 2014 XR1337. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
