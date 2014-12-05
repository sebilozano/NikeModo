//
//  PromotionCell.h
//  NikeModo
//
//  Created by hackathon on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionCell : UITableViewCell
{
    UIImageView *_thumbnail;
    UILabel *_titleLabel;
}

@property (nonatomic, retain) UIImageView *thumbnail;
@property (nonatomic, retain) UILabel *titleLabel;

@end
