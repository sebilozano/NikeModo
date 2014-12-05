//
//  ViewController.h
//  NikeModo
//
//  Created by Sacha Best on 10/24/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NikeLoginViewController.h"
#import "ParseManager.h"
#import "StyledPullableView.h"
#import "OfferTableViewData.h"
#import "SWTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "NikeTabBar.h"

@class NikeTabBar;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate> {
    UIImage *swoosh;
    UILabel *pullUpLabel;
    PullableView *pullScanView;
    UILabel *pullScanLabel;
    UIView *pullScanBack;
    PullableView *pullCartView;
    UILabel *pullCartLabel;
    UIView *pullCartBack;
    UIButton *pullCartFake;
    UITableView *pullUpTable;
    OfferTableViewData *data;
    UIPanGestureRecognizer *dragRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    UITableView *swipeTableView;
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *output;
    AVCaptureVideoPreviewLayer *prevLayer;
    UIView *highlightView;
    UILabel *label;
}

@property (weak, nonatomic) IBOutlet UIImageView *swooshView;
@property (weak, nonatomic) IBOutlet UIImageView *swooshProgress;
@property (weak, nonatomic) IBOutlet StyledPullableView *pulloutView;
@property (weak, nonatomic) IBOutlet UITableView *offerTable;
@property (weak, nonatomic) IBOutlet UILabel *labelLoyalty;
@property (weak, nonatomic) IBOutlet UILabel *labelNextLoyalty;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheckout;

@property (strong, nonatomic) NSMutableArray *cart;
@property (weak, nonatomic) IBOutlet NikeTabBar *tabBar;
@property (weak, nonatomic) IBOutlet UILabel *labelName;


@end

