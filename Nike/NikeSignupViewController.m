//
//  NikeSignupViewController.m
//  Nike
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "NikeSignupViewController.h"

@interface NikeSignupViewController ()

@end

@implementation NikeSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signUpView.backgroundColor = [UIColor blackColor];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swoosh"]];
    logo.bounds = CGRectMake(0, 0, 150, 150);
    logo.contentMode = UIViewContentModeScaleAspectFit;
    self.signUpView.logo = logo;
    self.signUpView.emailAsUsername = YES;
    self.minPasswordLength = 8;
    self.signUpView.additionalField.backgroundColor = [UIColor grayColor];
    self.signUpView.usernameField.backgroundColor = [UIColor grayColor];
    self.signUpView.passwordField.backgroundColor = [UIColor grayColor];
    self.signUpView.signUpButton.backgroundColor = [UIColor orangeColor];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.delegate = [ParseManager instance];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
