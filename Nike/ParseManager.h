//
//  ParseManager.h
//  NikeModo
//
//  Created by Vincent Do on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "NikeSignupViewController.h"

#ifndef NikeModo_ParseManager_h
#define NikeModo_ParseManager_h


#endif

#define MODOCLIENTID @"a9b0e8de3890517b01d6d130962c3e29"
#define MODOCLIENTSECRET @"4a0e3766021dd8cdadb06ac76023e72b9c903b184650c105a89d950fd9801b59"

@interface ParseManager : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property NSString * ACCESS_TOKEN;
@property NSString * CHECKOUT_TOKEN;

- (BOOL) isLoggedIn;
- (PFUser *) getCurrentUser;
- (void) logOut;
- (void) registerNewUser:(NSString *)phoneNumber;
- (void) getOffers:(id)target selector:(SEL)selector;
- (void) updateToken: (id)send selector:(SEL)selector withObject:(id) arg;
- (void) updateTokenWithNoCallBack;
- (void) registerCard;
- (void) getMerchant;
- (void) visitLocation;
- (void) checkOut:(id)target selector:(SEL)selector;

typedef enum LoyaltyLevel {
    Fan, Amateur, SemiPro, Professional, AllStar, Legend, Dynasty
} LoyaltyLevel;

- (LoyaltyLevel)getLoyaltyLevel:(int)points;
- (int)pointsToNextLevel:(int)points;
- (LoyaltyLevel)nextLevel:(LoyaltyLevel)current;
- (NSString *)nameOfLoyalty:(LoyaltyLevel)loyalty;
- (double)fractionComplete:(int)points;

+ (ParseManager *)instance;
- (UIImage *)imageWithColor:(UIColor *)color;

@end
