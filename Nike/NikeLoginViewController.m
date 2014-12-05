//
//  NikeLoginViewController.m
//  Nike
//
//  Created by Sacha Best on 11/1/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "NikeLoginViewController.h"

@interface NikeLoginViewController ()

@end

@implementation NikeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logInView.backgroundColor = [UIColor blackColor];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swoosh"]];
    logo.bounds = CGRectMake(0, 0, 150, 150);
    logo.contentMode = UIViewContentModeScaleAspectFit;
    self.logInView.emailAsUsername = YES;
    self.logInView.usernameField.backgroundColor = [UIColor grayColor];
    self.logInView.passwordField.backgroundColor = [UIColor grayColor];
    self.logInView.logInButton.backgroundColor = [UIColor orangeColor];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.logInView.signUpButton.backgroundColor = [UIColor orangeColor];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.signUpController = [[NikeSignupViewController alloc] init];
    ((NikeSignupViewController *)self.signUpController).loginVC = self;
    // for some reason this must be done here...
    [self.signUpController setFields:PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsAdditional];
    [self.signUpController.signUpView.additionalField setPlaceholder:@"Phone"];
    self.signUpController.signUpView.additionalField.textColor = [UIColor lightGrayColor];
    [self.logInView setLogo:logo];
    self.delegate = [ParseManager instance];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
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
