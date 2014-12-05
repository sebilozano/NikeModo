//
//  ParseManager.m
//  NikeModo
//
//  Created by Vincent Do on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager

static ParseManager *instance;

- (BOOL) isLoggedIn {
    return ([PFUser currentUser] != nil);
}

- (PFUser *) getCurrentUser {
    [[PFUser currentUser] fetchIfNeeded];
    return [PFUser currentUser];
}

- (void) logOut {
    [PFUser logOut];
}

- (void) getMerchant {
    NSString * MERCHANT_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/merchant/list";

    NSURL *url=[NSURL URLWithString: MERCHANT_URL];
    
    NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@",
                     self.ACCESS_TOKEN, MODOCLIENTID];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * JSONerror;
    NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
//    NSLog(postDataString);
    
    NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) {
             NSLog(@"Get Merchant Failed!");
             NSLog(@"Error: %@", error);
         }
         else {
             NSError * JSONError1;
             NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
             NSArray * responseData = [jsonData objectForKey:@"response_data"];
             for (int i = 0; i < [responseData count]; i++) {
                 NSDictionary * merchantData = responseData[i];
                 NSString * merchantId = merchantData[@"merchant_id"];
                 NSString * name = merchantData[@"merchant_name"];
                 NSArray * locations = merchantData[@"locations"];
                 
                 if (![name isEqualToString:@"Nike"]) continue;
                 
                 for (NSDictionary * location in locations) {
                     
                     NSString * locationId = location[@"locationId"];
                     NSString * locationName = location[@"locationName"];
                     NSString * latitude = location[@"latitude"];
                     NSString * longitude = location[@"longitude"];
                     
                     PFQuery * query = [PFQuery queryWithClassName:@"Locations"];
                     
                     NSArray * objects = [query findObjects];
                     
                     BOOL duplicate = FALSE;
                     
                     for (PFObject * object in objects) {
                         if ([((NSString *) object[@"locationId"]) isEqualToString:location[@"locationId"]]) {
                             duplicate = TRUE;
                             break;
                         }
                     }
                     
                     if (duplicate == TRUE) continue;
                     
                     PFObject *merchant = [PFObject objectWithClassName:@"Locations"];
                     [merchant setObject: merchantId forKey:@"merchantId"];
                     [merchant setObject: name forKey:@"merchantName"];
                     [merchant setObject: locationId forKey:@"locationId"];
                     [merchant setObject: locationName forKey:@"locationName"];
                     
                     PFGeoPoint * geoPoint = [PFGeoPoint geoPointWithLatitude:[latitude doubleValue] longitude: [longitude doubleValue]];

                     [merchant setObject:geoPoint forKey:@"geoPoint"];
                     
                     [merchant saveInBackground];
                 }
             }
             NSLog(@"Add Merchant List Response Data: %@", responseData);
         }
     }];
}

- (void) checkOut:(id)target selector:(SEL)selector {
    
    NSString * MERCHANT_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/location/checkout";
    
    NSURL *url=[NSURL URLWithString: MERCHANT_URL];
    
    PFUser * currentUser = [self getCurrentUser];
    NSString * checkOutAmount = @"9000";
    
    NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@&account_id=%@&checkout_amount=%@&checkout_code=%@",
                     self.ACCESS_TOKEN, MODOCLIENTID, currentUser[@"accountId"], checkOutAmount, self.CHECKOUT_TOKEN ];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * JSONerror;
    NSString * postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    //    NSLog(postDataString);
    
    NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) {
             NSLog(@"Checkout Failed!");
             NSLog(@"Error: %@", error);
         }
         else {
             NSError * JSONError1;
             NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
             NSArray * responseData = [jsonData objectForKey:@"response_data"];
           
             NSLog(@"Checkout Response Data: %@", responseData);
         }
         if (target)
             [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
     }];

    
}

- (LoyaltyLevel)getLoyaltyLevel:(int)points {
    if (points > 5000) {
        return Dynasty;
    } else if (points > 1000) {
        return Legend;
    } else if (points > 500) {
        return AllStar;
    } else if (points > 250) {
        return Professional;
    } else if (points > 100) {
        return SemiPro;
    } else {
        return Amateur;
    }
}
- (int)pointsToNextLevel:(int)points {
    if (points > 5000) {
        return -1;
    } else if (points > 1000) {
        return 5000 - points;
    } else if (points > 500) {
        return 1000 - points;
    } else if (points > 250) {
        return 500 - points;
    } else if (points > 100) {
        return 250 - points;
    } else {
        return 100 - points;
    }
}
- (double)fractionComplete:(int)points {
    if (points > 5000) {
        return 1;
    } else if (points > 1000) {
        return points / 5000.0;
    } else if (points > 500) {
        return points / 1000.0;
    } else if (points > 250) {
        return points / 500.0;
    } else if (points > 100) {
        return points / 250.0;
    } else {
        return points / 100.0;
    }
}
- (LoyaltyLevel)nextLevel:(LoyaltyLevel)current {
    if (current == Dynasty)
        return -1;
    return (LoyaltyLevel) current + 1;
}
- (NSString *)nameOfLoyalty:(LoyaltyLevel)loyalty {
    switch (loyalty) {
        case Amateur:
            return @"Amateur";
        case SemiPro:
            return @"Semi-Pro";
        case Professional:
            return @"Professional";
        case AllStar:
            return @"All-Star";
        case Legend:
            return @"Legend";
        case Dynasty:
            return @"Dynasty";
        default:
            return @"";
    }
}

- (BOOL) signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    
    NSString * phoneNumber = [info objectForKey:@"additional"];
    NSLog(@"%@", phoneNumber);
    [self updateToken:self selector:@selector(registerNewUser:) withObject: phoneNumber];
    [signUpController dismissViewControllerAnimated:YES completion:^{
        [((NikeSignupViewController *)signUpController).loginVC dismissViewControllerAnimated:NO completion:^{
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }];
    }];
    return TRUE;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [logInController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }];
}

- (void) updateTokenWithNoCallBack {
    if (self.ACCESS_TOKEN == nil) {
        NSString * TOKEN_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/token";
        
        @try {
            NSString * CREDENTIALS_RAW = [MODOCLIENTID stringByAppendingString:@":"];
            CREDENTIALS_RAW = [CREDENTIALS_RAW stringByAppendingString: MODOCLIENTSECRET];
            
            NSData *plainData = [CREDENTIALS_RAW dataUsingEncoding:NSUTF8StringEncoding];
            NSString *ENCODED_CREDENTIALS = [plainData base64EncodedStringWithOptions:0];
            
            NSString *post =[[NSString alloc] initWithFormat:@"credentials=%@", ENCODED_CREDENTIALS ];
            
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString: TOKEN_URL];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *postLength = [NSString stringWithFormat:@"%d", postData.length];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %d", [response statusCode]);
            
            if ([response statusCode] >=200 && [response statusCode] <300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                
                NSError * JSONError;
                NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&JSONError];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"status_code"] integerValue];
                NSLog(@"%d",success);
                if(success == 0)
                {
                    NSLog(@"Login SUCCESS");
                    NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
                    self.ACCESS_TOKEN = [responseData objectForKey:@"access_token"];
//                    [send performSelector: selector withObject:arg];
                } else {
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    NSLog(error_msg);
                }
                
            } else {
                if (error) NSLog(@"Error: %@", error);
            }
        }
        @catch (NSException * e) {
            
        }
    }
}

- (void) updateToken: (id)send selector:(SEL)selector withObject:(id) arg {

    
    if (self.ACCESS_TOKEN != nil) {
        [send performSelector: selector withObject:arg];
    }
    else {
        
        NSString * TOKEN_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/token";
        
        @try {
            NSString * CREDENTIALS_RAW = [MODOCLIENTID stringByAppendingString:@":"];
            CREDENTIALS_RAW = [CREDENTIALS_RAW stringByAppendingString: MODOCLIENTSECRET];
            
            NSData *plainData = [CREDENTIALS_RAW dataUsingEncoding:NSUTF8StringEncoding];
            NSString *ENCODED_CREDENTIALS = [plainData base64EncodedStringWithOptions:0];
            
            NSString *post =[[NSString alloc] initWithFormat:@"credentials=%@", ENCODED_CREDENTIALS ];
            
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString: TOKEN_URL];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *postLength = [NSString stringWithFormat:@"%d", postData.length];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %d", [response statusCode]);
            
            if ([response statusCode] >=200 && [response statusCode] <300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                
                NSError * JSONError;
                NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&JSONError];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"status_code"] integerValue];
                NSLog(@"%d",success);
                if(success == 0)
                {
                    NSLog(@"Login SUCCESS");
                    NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
                    self.ACCESS_TOKEN = [responseData objectForKey:@"access_token"];
                    [send performSelector: selector withObject:arg];
                } else {
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    NSLog(error_msg);
                }
                
            } else {
                if (error) NSLog(@"Error: %@", error);
            }
        }
        @catch (NSException * e) {
            
        }
    }
}

- (void) registerCard {
    
//    NSString * PHONE = phoneNumber;
    NSString * REGISTER_CARD_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/card/add";
    NSString * CARD_NUM = @"4124939999999990";
    NSString * EXP = @"1220";
    NSString * ZIP = @"19104";
    
    PFUser * currentUser = [PFUser currentUser];
    
//    NSString * AGREE = @"1";
    NSURL *url=[NSURL URLWithString: REGISTER_CARD_URL];
    
    NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@&account_id=%@&card_number=%@&expiry=%@&zip_code=%@",
                     self.ACCESS_TOKEN, MODOCLIENTID, currentUser[@"accountId"], CARD_NUM, EXP, ZIP];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * JSONerror;
    NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    NSLog(postDataString);
    
    NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) {
             NSLog(@"Card Registration Failed!");
             NSLog(@"Error: %@", error);
         }
         else {
             NSError * JSONError1;
             NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
             NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
             NSLog(@"Add Card Response Data: %@", responseData);
         }
     }];
}



// [ClassName methodName:arugment methodpart2:argument2];
- (void) registerNewUser: (NSString *)phoneNumber {
    NSLog(@"registering....");
    
    @try {
        NSString * PHONE = phoneNumber;
        NSString * REGISTER_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/people/register";
        NSString * AGREE = @"1";
        NSURL *url=[NSURL URLWithString: REGISTER_URL];
        
        NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@&phone=%@&is_modo_terms_agree=%@", self.ACCESS_TOKEN, MODOCLIENTID, PHONE, AGREE];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
        NSError * JSONerror;
        NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        NSLog(postDataString);
        
        NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if (error) {
                NSLog(@"Registration Failed!");
                NSLog(@"Error: %@", error);
            }
            else {
                NSError * JSONError1;
                NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
                NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
                NSString * accountId = [responseData objectForKey:@"account_id"];
                PFUser *currentUser = [PFUser currentUser];
                
                [currentUser setObject:accountId forKey:@"accountId"];
                [currentUser setObject:phoneNumber forKey:@"phoneNumber"];
                [currentUser saveInBackground ];
                
                NSLog(@"Update Succeeded in Parse");
            }
        }];
    }
    
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

- (void) getOffers:(id)target selector:(SEL)selector {
    
    PFUser * currentUser = [self getCurrentUser];
    NSString * accountId = [currentUser objectForKey:@"accountId"];
    
    NSString * OFFER_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/offer/lookup";
    NSURL *url=[NSURL URLWithString: OFFER_URL];
    
    NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@&account_id=%@", self.ACCESS_TOKEN, MODOCLIENTID, accountId];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * JSONerror;
    NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
//    NSLog(postDataString);
    
    NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) {
             NSLog(@"Failed to Pull Offer!");
             NSLog(@"Error: %@", error);
         }
         else {
             NSError * JSONError1;
             NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
//             NSLog(@"%@", jsonData);
             NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
             if (responseData == nil) return;
             NSArray * offers =[responseData objectForKey:@"offers"];
             
             for (int i = 0; i < [offers count]; i++) {
                 NSDictionary * offerData = offers[i];
                 
                 NSString * expirationDate = [offerData objectForKey:@"date_expiry"];
                 NSString * message = [offerData objectForKey:@"user_message"];
                 NSString * merchant = [offerData objectForKey:@"giver_name"];
                 NSString * offerId = offerData[@"invite_id"];
                 
                 if (![merchant isEqualToString:@"Nike"]) {
                     continue;
                 }
                 
                 
                 PFQuery * query = [PFQuery queryWithClassName:@"Offers"];
                 [query whereKey:@"owner" equalTo:currentUser];
                 NSArray *objects = [query findObjects];
                 
                
                 BOOL duplicate = FALSE;
                 for (PFObject *object in objects) {
                     if ([((NSString *)object[@"offerId"]) isEqualToString: offerId]) {
                         duplicate = TRUE;
                         break;
                     }
                 }
                 if (duplicate == TRUE) continue;
                 
                 PFObject * offer = [PFObject objectWithClassName:@"Offers"];
                 [offer setObject:currentUser forKey:@"owner"];
                 [offer setObject:expirationDate forKey:@"description"];
                 [offer setObject:message forKey:@"title"];
                 [offer setObject:merchant forKey:@"merchant"];
                 [offer setObject:offerId forKey:@"offerId"];
                 [offer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     NSLog(@"Update Succeeded in Parse");
                     [target performSelector:selector withObject:nil];
                 }];
             }
             
         }
     }];
}

- (void) visitLocation {
    
    PFQuery * query = [PFQuery queryWithClassName:@"Locations"];
    NSArray * locations = [query findObjects];
    
    NSString * locationId = @"aa589a29f0274ed3aae5a1ceed68c623"; // Beverly Hills
    NSString * merchantId = @"9a99363ec16a4e1a86addd8a92875484";
    
    NSString * VISIT_URL = @"https://api.sbx.gomo.do/YiiModo/api_v2/location/visit";
    NSURL *url=[NSURL URLWithString: VISIT_URL];
    
    PFUser *currentUser = [self getCurrentUser];
    NSString * accountId = currentUser[@"accountId"];
    
    NSString *post =[[NSString alloc] initWithFormat:@"access_token=%@&consumer_key=%@&account_id=%@&location_id=%@&merchant_id=%@&intent_ignore_gifts=%@",
                     self.ACCESS_TOKEN, MODOCLIENTID, accountId, locationId, merchantId, @"1"];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * JSONerror;
    NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    //    NSLog(postDataString);
    
    NSString * postLength = [NSString stringWithFormat:@"%d", postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) {
             NSLog(@"Failing to Check In to Store!");
             NSLog(@"Error: %@", error);
         }
         else {
             NSError * JSONError1;
             NSDictionary *jsonData = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError1];
             NSDictionary * responseData = [jsonData objectForKey:@"response_data"];
             self.CHECKOUT_TOKEN = responseData[@"checkout_code"];
             NSLog(@"CHECKOUT_CODE: %@", self.CHECKOUT_TOKEN);
         }
     }];
}


+ (ParseManager *)instance {
    if (!instance) {
        instance = [[ParseManager alloc] init];
    }
    return instance;
}
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end