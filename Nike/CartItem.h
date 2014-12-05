//
//  CartItem.h
//  Nike
//
//  Created by hackathon on 11/2/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CartItem : NSObject

@property (nonatomic,strong) NSString* itemName;
@property (nonatomic,strong) NSString* price;
@property (nonatomic,strong) NSURL* imageURL;

-(id)initWithName:(NSString *)name withPrice:(NSString *)price withURL:(NSURL *)imageURL;

-(UIImage *)getImage;

@end
