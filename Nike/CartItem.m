//
//  CartItem.m
//  Nike
//
//  Created by hackathon on 11/2/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "CartItem.h"

@implementation CartItem

-(id)initWithName:(NSString *)name withPrice:(NSString *)price withURL:(NSURL *)imageURL;
{
    self = [super init];
    self.price = price;
    self.itemName = name;
    self.imageURL = imageURL;
    
    return self;
}

-(UIImage *)getImage {
    NSData *data = [NSData dataWithContentsOfURL:self.imageURL];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

@end
