
//
//  NikeTabBarItem.m
//  NikeModo
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "NikeTabBarItem.h"

@implementation NikeTabBarItem

- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag {
    double fontSize = 18.0;
    if ([title isEqualToString:@"HOME"]) {
        fontSize = 24.0;
    }
    NikeTabBarItem *new = [super initWithTitle:title image:nil tag:tag];
    new.image = [image imageWithRenderingMode:UIImageRenderingModeAutomatic];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Myriad Pro" size:fontSize], NSFontAttributeName, [UIColor whiteColor], UITextAttributeTextColor, nil];
    [new setTitleTextAttributes:dic forState:UIControlStateNormal];
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Myriad Pro" size:fontSize], NSFontAttributeName, [UIColor orangeColor], UITextAttributeTextColor, nil];
    [new setTitleTextAttributes:dic2 forState:UIControlStateSelected];
    new.titlePositionAdjustment = UIOffsetMake(0, -20.0f);
    return new;
}
@end
