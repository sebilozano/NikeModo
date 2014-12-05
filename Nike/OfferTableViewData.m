//
//  OfferTableViewData.m
//  Nike
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "OfferTableViewData.h"

@implementation OfferTableViewData

static NSString *reuse = @"Offer";

- (void)queryParse:(UITableView *)tableView {
    PFQuery *classQuery = [PFQuery queryWithClassName:@"Offers"];
    // insert loading indicator here
    [classQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
    [classQuery orderByDescending:@"createdAt"];
    [classQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        parseObjects = objects;
        [tableView reloadData];
    }];
}

- (id)initWithTableView:(UITableView *)tableView {
    OfferTableViewData *new = [super init];
    new.tableView = tableView;
    if ([[ParseManager instance] isLoggedIn])
        [self queryParse:tableView];
    return new;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return parseObjects.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"OFFERS";
}
// -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
-   (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[OfferTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    cell.labelTitle.textColor = [UIColor orangeColor];
    cell.labelTitle.text = parseObjects[indexPath.row][@"title"];
    cell.labelDescription.textColor = [UIColor whiteColor];
    cell.labelDescription.text = parseObjects[indexPath.row][@"description"];
    return cell;
}
@end
