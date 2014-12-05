//
//  NikeTabBar.m
//  NikeModo
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "NikeTabBar.h"
#import "ViewController.h"

@implementation NikeTabBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    NikeTabBar *new = [super initWithCoder:aDecoder];
    //new.backgroundColor = [UIColor clearColor];
    new.backgroundImage = [UIImage imageNamed:@"transparent"];
    //new.superview.backgroundColor = [UIColor clearColor];
    new.tintColor = [UIColor orangeColor];
    // THIS MUST ALSO BE SET FROM VIEWDIDLOAD
    new.buttons = [[NSMutableArray alloc] init];
    [new.buttons addObject:[new createWithTitle:@"SCAN" index:0]];
    [new.buttons addObject:[new createWithTitle:@"HOME" index:1]];
    [new.buttons addObject:[new createWithTitle:@"YOU" index:2]];
    new.items = [new.buttons copy];
    [new setSelectedItem:new.items[1]];
    self.delegate = self;
    return new;
}
- (UITabBarItem *)createWithTitle:(NSString *)title index:(int)index {
    UIImage *background = nil;
    if ([title isEqualToString:@"PAY"]) {
        //background = [NikeTabBar imageWithColor:[UIColor orangeColor]];
    } else {
        //background = [NikeTabBar imageWithColor:[UIColor grayColor]];
    }
    NikeTabBarItem *new = [[NikeTabBarItem alloc] initWithTitle:title image:background tag:index];
    // insert customization code here
    return new;
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSString *title = item.title;
    if ([title isEqualToString:@"SCAN"]) {
        [self.MainViewController performSegueWithIdentifier:@"toScanner" sender:self.MainViewController];
    } else if ([title isEqualToString:@"ACCOUNT"]) {
        
    } else if ([title isEqualToString:@"HOME"]) {
        
    } else if ([title isEqualToString:@"OFFERS"]) {
        
    } else if ([title isEqualToString:@"PROFILE"]) {
        
    }
}

/*
- (void)buttonClicked:(NSString *)title {
    if ([title isEqualToString:@"PAY"]) {
    }
}*/

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
