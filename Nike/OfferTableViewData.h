//
//  OfferTableViewData.h
//  Nike
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfferTableViewCell.h"

@interface OfferTableViewData : NSObject <UITableViewDelegate, UITableViewDataSource> {
    NSArray *parseObjects;
}

@property UITableView *tableView;
- (id)initWithTableView:(UITableView *)tableView;
- (void)queryParse:(UITableView *)tableView;

@end
