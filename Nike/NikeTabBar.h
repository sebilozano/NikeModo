//
//  NikeTabBar.h
//  NikeModo
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NikeTabBarItem.h"
#import "ViewController.h"

@interface NikeTabBar : UITabBar <UITabBarDelegate>

@property NSMutableArray *buttons;
@property (nonatomic, weak) IBOutlet UIViewController *MainViewController;

@end
