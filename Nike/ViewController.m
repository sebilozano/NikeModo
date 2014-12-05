//
//  ViewController.m
//  NikeModo
//
//  Created by Sacha Best on 10/24/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "ViewController.h"
#import "BarcodeScannerViewController.h"
#import "NikeTabBar.h"
#import <UPPlatformSDK/UPPlatformSDK.h>
#import "SWTableViewCell.h"
#import "CartItem.h"
#import <QuartzCore/QuartzCore.h>

// OAuth keys.
NSString *const kAPIExplorerID = @"tvSKu1JF1ek";
NSString *const kAPIExplorerSecret = @"2c41687950270f26e8158a6e822cf7d61bd44de3";

@interface ViewController () {
    NSArray *_sections;
}

//@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UPPlatform sharedPlatform].enableNetworkLogging = YES;
    
    [self joyceAndNova];
    data = [[OfferTableViewData alloc] initWithTableView:_offerTable];
    _offerTable.delegate = data;
    _offerTable.dataSource = data;
    
    //UIButton *tempCard = [UIButton buttonWithType: UIButtonTypeSystem];
    //[tempCard setFrame:CGRectMake(0, 180, 320, 64)];
    //[tempCard setTitle:@"Vincent is a noob" forState:UIControlStateNormal];
    //[tempCard addTarget:self action:@selector(checkoutfire) forControlEvents:UIControlEventAllEvents];
    //[self.view addSubview:tempCard];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRecording) name:@"BAR-OPEN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecording) name:@"BAR-CLOSE" object:nil];

    if ([[ParseManager instance] isLoggedIn]) {
        [data queryParse:_offerTable];
        int currentLoyalty = [[[ParseManager instance] getCurrentUser][@"loyaltyPoints"] intValue];
        LoyaltyLevel current = [[ParseManager instance] getLoyaltyLevel:currentLoyalty];
        LoyaltyLevel next = [[ParseManager instance] nextLevel:current];
        NSString *nextLoyalty = [[ParseManager instance] nameOfLoyalty:next];
        int poointsToNext = [[ParseManager instance] pointsToNextLevel:currentLoyalty];
        _labelLoyalty.text = [[ParseManager instance] nameOfLoyalty:current];
        _labelNextLoyalty.text = [NSString stringWithFormat:@"%d points to %@", poointsToNext, nextLoyalty];
        [self fillSwooshToPercentage:[[ParseManager instance] fractionComplete:currentLoyalty]];
    }
    // Do any additional setup after loading the view, typically from a nib.
    
    /*****/
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    swipeTableView.rowHeight = 90;
    
    self.navigationItem.title = @"Pull to Toggle Cell Type";
    
    // Setup refresh control for example app
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    //[self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        swipeTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    
    _sections = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    
    self.cart = [[NSMutableArray alloc] init];
    
    self.useCustomCells = NO;
}

- (void)checkoutfire {
  //  [[ParseManager instance] checkOut:nil selector:nil];
}

- (void)joyceAndNova {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    
    /**************CART VIEW*************************/
    
    pullCartView = [[PullableView alloc] initWithFrame:CGRectMake(0, 0, w - 30, h - 72)];
    pullCartView.backgroundColor = [UIColor clearColor];
    pullCartView.alpha = 0.9;
    pullCartView.openedCenter = CGPointMake(w / 2 - 15, h / 2 + 36);
    pullCartView.closedCenter = CGPointMake(w + w / 2 - 45, h / 2 + 36);
    pullCartView.center = pullCartView.closedCenter;
    pullCartView.animate = NO;
    
    pullCartView.handleView.backgroundColor = [UIColor clearColor];
    pullCartView.handleView.frame = CGRectMake(0, 0, 30, 100);
    
    pullCartFake = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    pullCartFake.backgroundColor = [UIColor orangeColor];
    pullCartFake.frame = CGRectMake(0, 0, 30, 100);
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:pullCartFake.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft)
                                           cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = pullCartFake.bounds;
    maskLayer.path = maskPath.CGPath;
    pullCartFake.layer.mask = maskLayer;
    
    /*********PULL CART FAKE EVENT HANDLING*********************/
    [pullCartFake addTarget:self action:@selector(pullCartBool) forControlEvents:(UIControlEventTouchUpInside)];
    
    pullCartLabel = [[UILabel alloc] initWithFrame:CGRectMake(-33, 75 - w * 9.35/10, 100, h - 72)];
    pullCartLabel.font = [UIFont fontWithName:@"Myriad Pro" size:16];
    pullCartLabel.textColor = [UIColor darkGrayColor];
    pullCartLabel.text = @"MY CART";
    [pullCartLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    pullCartBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w - 30, h - 72)];
    pullCartBack.frame = CGRectMake(30, 0, w - 30, h - 72);
    pullCartBack.backgroundColor = [UIColor lightGrayColor];
    
    [pullCartView addSubview:pullCartBack];
    [pullCartView addSubview:pullCartFake];
    [self.view addSubview:pullCartView];
    [pullCartView addSubview:pullCartLabel];
    [pullCartView bringSubviewToFront:pullCartLabel];
    
    [pullCartView setToggleOnTap:(TRUE)];
    
    dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:pullCartView action:@selector(handleDrag:)];
    dragRecognizer.minimumNumberOfTouches = 1;
    dragRecognizer.maximumNumberOfTouches = 1;
    
    [pullCartFake addGestureRecognizer:dragRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:pullCartView action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    
    [pullCartFake addGestureRecognizer:tapRecognizer];
    [_buttonCheckout addTarget:self action:@selector(showCart) forControlEvents:UIControlEventAllTouchEvents];
    
    /**********SCAN VIEW*****************************/
    
    pullScanView = [[PullableView alloc] initWithFrame:CGRectMake(0, 0, w + 60, h - 72)];
    pullScanView.backgroundColor = [UIColor clearColor];
    pullScanView.alpha = 1.0;
    pullScanView.openedCenter = CGPointMake(w / 2, h / 2 + 36);
    pullScanView.closedCenter = CGPointMake(w + w / 2, h / 2 + 36);
    pullScanView.center = pullScanView.closedCenter;
    pullScanView.animate = NO;
    
    pullScanView.handleView.backgroundColor = [UIColor orangeColor];
    pullScanView.handleView.frame = CGRectMake(0, 110, 30, 100);
    pullScanView.handleView.alpha = 0.9;
    
    UIBezierPath *maskPath2;
    maskPath2 = [UIBezierPath bezierPathWithRoundedRect:pullScanView.handleView.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft)
                                           cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = pullScanView.handleView.bounds;
    maskLayer2.path = maskPath2.CGPath;
    pullScanView.handleView.layer.mask = maskLayer2;
    
    pullScanBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h - 72)];
    pullScanBack.frame = CGRectMake(30, 0, w, h - 72);
    pullScanBack.backgroundColor = [UIColor lightGrayColor];
    [self addBarcodeScannerToView:pullScanBack sender:self];

    
    pullScanLabel = [[UILabel alloc] initWithFrame:CGRectMake(-33, 75 - w * 9.2 / 10, 100, h - 72)];
    pullScanLabel.font = [UIFont fontWithName:@"Myriad Pro" size:16];
    pullScanLabel.backgroundColor = [UIColor clearColor];
    pullScanLabel.textColor = [UIColor darkGrayColor];
    pullScanLabel.text = @"SCAN ITEM";
    [pullScanLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    //handle for scan view
    [pullScanView.handleView addSubview:pullScanLabel];
    [self.view addSubview:pullScanView];
    [pullScanView addSubview:pullScanBack];
    
    //allows opening cart view when blocked by scan view
    [pullScanView addSubview:pullCartView.handleView];
    
    /**************** CART TABLE VIEW *******************/
    float width = [[UIScreen mainScreen] bounds].size.width - 30;
    UIButton *checkout = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *clear = [UIButton buttonWithType:UIButtonTypeCustom];
    checkout.frame = CGRectMake(0, 0, width / 2.0, 60);
    clear.frame = CGRectMake((width / 2.0) + 30, 0, width / 2.0, 60);
    checkout.backgroundColor = [UIColor orangeColor];
    clear.backgroundColor = [UIColor blackColor];
    checkout.font = [UIFont fontWithName:@"Myriad Pro" size:20.0f];
    clear.font = [UIFont fontWithName:@"Myriad Pro" size:20.0f];
    checkout.titleLabel.textColor = [UIColor whiteColor];
    clear.titleLabel.textColor = [UIColor whiteColor];
    [checkout setTitle:@"CHECKOUT" forState:UIControlStateNormal];
    [checkout setTitle:@"CHECKOUT" forState:UIControlStateHighlighted];
    [clear setTitle:@"CLEAR" forState:UIControlStateNormal];
    [clear setTitle:@"CLEAR" forState:UIControlStateHighlighted];
    [checkout addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchDown];
    [clear addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchDown];
    [pullCartBack addSubview:checkout];
    [pullCartView addSubview:clear];
    swipeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, w, h - 132) style:UITableViewStylePlain];
    [swipeTableView setAutoresizesSubviews:YES];
    [swipeTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [swipeTableView registerClass:[SWTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [swipeTableView setDataSource:self];
    [swipeTableView setDelegate:self];
    
    [pullCartBack addSubview:swipeTableView];
    /****************************************************/
    
    /***************SCAN BUTTON**************************//*
    UIButton *roundButton = [UIButton buttonWithType: UIButtonTypeSystem];
    [roundButton setFrame:CGRectMake(0, 150, 320, 64)];
    [roundButton se
                                                           tTitle:@"Add Item to Cart" forState:UIControlStateNormal];
    [roundButton addTarget:(_pulloutView) action: @selector(menuItemAdded) forControlEvents:(UIControlEventTouchUpInside)];
    [pullScanBack addSubview:roundButton];
    *//****************************************************/
}
- (void)checkout {
    [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[ParseManager instance] checkOut:self selector:@selector(stopSpinner)];
}
- (void)stopSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [PF_MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    [self pullCartBool];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkout Success!" message:@"You will recieve a receipt shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)clear {
    [self.cart removeAllObjects];
    [swipeTableView reloadData];
}
- (void)pullCartBool {
    NSNumber *arg1 = [NSNumber numberWithBool:NO];
    NSNumber *arg2 = [NSNumber numberWithBool:YES];
    [pullCartView performSelector:@selector(setOpened:animated:) withObject:arg1 withObject:arg2];
}
- (void)pullScanBool {
    NSNumber *arg1 = [NSNumber numberWithBool:NO];
    NSNumber *arg2 = [NSNumber numberWithBool:YES];
    [pullScanView performSelector:@selector(setOpened:animated:) withObject:arg1 withObject:arg2];
}
- (void)showCart {
    NSNumber *arg1 = [NSNumber numberWithBool:YES];
    NSNumber *arg2 = [NSNumber numberWithBool:YES];
    [pullCartView performSelector:@selector(setOpened:animated:) withObject:arg1 withObject:arg2];
}
- (void)viewWillAppear:(BOOL)animated {
    [_tabBar setSelectedItem:_tabBar.items[1]];
    if ([[ParseManager instance] isLoggedIn]) {
        _labelName.text = [[ParseManager instance] getCurrentUser].username;
        int currentLoyalty = [[[ParseManager instance] getCurrentUser][@"loyaltyPoints"] intValue];
        LoyaltyLevel current = [[ParseManager instance] getLoyaltyLevel:currentLoyalty];
        LoyaltyLevel next = [[ParseManager instance] nextLevel:current];
        NSString *nextLoyalty = [[ParseManager instance] nameOfLoyalty:next];
        int poointsToNext = [[ParseManager instance] pointsToNextLevel:currentLoyalty];
        _labelLoyalty.text = [[ParseManager instance] nameOfLoyalty:current];
        _labelNextLoyalty.text = [NSString stringWithFormat:@"%d points to %@", poointsToNext, nextLoyalty];
        [self fillSwooshToPercentage:[[ParseManager instance] fractionComplete:currentLoyalty]];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    if (![[ParseManager instance] isLoggedIn]) {
        [self presentViewController:[[NikeLoginViewController alloc] init] animated:YES completion:^{
           // [self refreshOfferTable];
        }];
    } else {
        [[ParseManager instance] visitLocation];
        [[ParseManager instance] getOffers:self selector:@selector(refreshOfferTable)];
        
        _labelName.text = [[ParseManager instance] getCurrentUser].username;
        int currentLoyalty = [[[ParseManager instance] getCurrentUser][@"loyaltyPoints"] intValue];
        LoyaltyLevel current = [[ParseManager instance] getLoyaltyLevel:currentLoyalty];
        LoyaltyLevel next = [[ParseManager instance] nextLevel:current];
        NSString *nextLoyalty = [[ParseManager instance] nameOfLoyalty:next];
        int poointsToNext = [[ParseManager instance] pointsToNextLevel:currentLoyalty];
        _labelLoyalty.text = [[ParseManager instance] nameOfLoyalty:current];
        _labelNextLoyalty.text = [NSString stringWithFormat:@"%d points to %@", poointsToNext, nextLoyalty];
        [self fillSwooshToPercentage:[[ParseManager instance] fractionComplete:currentLoyalty]];
        /*
        
        [[UPPlatform sharedPlatform] validateSessionWithCompletion:^(UPSession *UPsession, NSError *error) {
            if (UPsession == nil) {
                [[UPPlatform sharedPlatform] startSessionWithClientID:kAPIExplorerID
                                                         clientSecret:kAPIExplorerSecret
                                                            authScope:UPPlatformAuthScopeAll
                                                           completion:^(UPSession *session, NSError *error) {
        if (UPsession != nil) {
                                                                   
        [UPWorkoutAPI getWorkoutsWithLimit:10 completion:^(NSArray *results, UPURLResponse *response, NSError *error) {
            double sum = 0;
            for (UPWorkout *workout in results) {
                sum += [workout.activeCalories floatValue];
            }
            int workoutPoints = sum/500;
            [data queryParse:_offerTable];
            int currentLoyalty = [[[ParseManager instance] getCurrentUser][@"loyaltyPoints"] intValue];
            LoyaltyLevel current = [[ParseManager instance] getLoyaltyLevel:currentLoyalty];
            LoyaltyLevel next = [[ParseManager instance] nextLevel:current];
            NSString *nextLoyalty = [[ParseManager instance] nameOfLoyalty:next];
            int poointsToNext = [[ParseManager instance] pointsToNextLevel:currentLoyalty];
            _labelLoyalty.text = [[ParseManager instance] nameOfLoyalty:current];
            _labelNextLoyalty.text = [NSString stringWithFormat:@"%d points to %@", poointsToNext, nextLoyalty];
            int totalLoyalty = workoutPoints + currentLoyalty;
            NSLog(@"%d", totalLoyalty);
            NSLog(@"%d", currentLoyalty);
            [self fillSwooshToPercentage:[[ParseManager instance] fractionComplete:totalLoyalty]];
            }];
                                                               } else {
                                                                   [data queryParse:_offerTable];
                                                                   int currentLoyalty = [[[ParseManager instance] getCurrentUser][@"loyaltyPoints"] intValue];
                                                                   LoyaltyLevel current = [[ParseManager instance] getLoyaltyLevel:currentLoyalty];
                                                                   LoyaltyLevel next = [[ParseManager instance] nextLevel:current];
                                                                   NSString *nextLoyalty = [[ParseManager instance] nameOfLoyalty:next];
                                                                   int poointsToNext = [[ParseManager instance] pointsToNextLevel:currentLoyalty];
                                                                   _labelLoyalty.text = [[ParseManager instance] nameOfLoyalty:current];
                                                                   _labelNextLoyalty.text = [NSString stringWithFormat:@"%d points to %@", poointsToNext, nextLoyalty];
                                                                   [self fillSwooshToPercentage:[[ParseManager instance] fractionComplete:currentLoyalty]];
                                                               }
                                                           }];
            }
        }]; */
    }

}

-(void)refreshOfferTable {
    [data queryParse:_offerTable];
}
-(UIImage *)maskImageOfSize:(CGRect)bounds filledTo:(CGFloat )percentage{
    
    UIGraphicsBeginImageContextWithOptions ( bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGRect fillRect = CGRectZero;
    fillRect.size.height = bounds.size.height;
    fillRect.size.width = bounds.size.width * percentage;
    fillRect.origin.x = bounds.origin.x;
    fillRect.origin.y = bounds.origin.y;
    CGContextFillRect(context, fillRect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(void)fillSwooshToPercentage:(CGFloat) percentage {
    percentage = (CGFloat) fmaxf(0.0 , (fminf(100.0, (float) percentage)));
    UIImage *toMask = [self maskImageOfSize:_swooshView.bounds filledTo:percentage];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = _swooshView.bounds;
    maskLayer.contents = (id)_swooshView.image.CGImage;
    _swooshProgress.image = toMask;
    _swooshProgress.layer.mask = maskLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened {
  pullUpLabel.text = @"Your Cart";
}

/*****/

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cart.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell selected at index path %ld:%ld", (long)indexPath.section, (long)indexPath.row);
    NSLog(@"selected cell index path is %@", [tableView indexPathForSelectedRow]);
    
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


// Show index titles

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//}

#pragma mark - UIRefreshControl Selector

- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    [refreshControl beginRefreshing];
    self.useCustomCells = !self.useCustomCells;
    if (self.useCustomCells)
    {
        self.refreshControl.tintColor = [UIColor yellowColor];
    }
    else
    {
        self.refreshControl.tintColor = [UIColor blueColor];
    }
    [swipeTableView reloadData];
    [refreshControl endRefreshing];
}

#pragma mark - UIScrollViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cartCell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.leftUtilityButtons = [self rightButtons];
        //cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    }
    
    CartItem *item = self.cart[indexPath.row];
    NSString *name = item.itemName;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:item.imageURL]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.textLabel.text = name;
    cell.detailTextLabel.text = item.price;
    
    
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}


- (void)swipeTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left button 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"More button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [swipeTableView indexPathForCell:cell];
            
            [self.cart[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
            [swipeTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)addToCart: (PFObject *)item {
    NSString *itemName = [item objectForKey:@"itemName"];
    NSURL *imageURL = [NSURL URLWithString:[item objectForKey:@"imageURL"]];
    NSString *price = [item objectForKey:@"price"];
    CartItem *cartItem = [[CartItem alloc] initWithName:itemName withPrice:price withURL:imageURL];
    [self.cart addObject:cartItem];
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            label.text = detectionString;
            
            [self getItemData:detectionString];
            
            [session stopRunning];
        }
        else
            label.text = @"(none)";
    }
    
    highlightView.frame = highlightViewRect;
}

- (void) getItemData: (NSString *)scannedBarcode {
    
    PFQuery *itemQuery = [PFQuery queryWithClassName:@"CartItem"];
    [itemQuery whereKey:@"barcode" equalTo:scannedBarcode];
    
    [itemQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [self performSelectorOnMainThread:@selector(presentErrorAlert) withObject:self waitUntilDone:NO];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            if (object != nil) {
                [self performSelectorOnMainThread:@selector(presentAddedAlert:) withObject:object waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(presentErrorAlert) withObject:self waitUntilDone:NO];
            }
        }
    }];
}

- (void) presentAddedAlert: (PFObject *)item {
    NSString *itemName = [item objectForKey:@"itemName"];
    NSString *add = @"Add ";
    NSString *toCart = @"to cart?";
    NSString *alertt = [add stringByAppendingString:itemName];
    alertt = [alertt stringByAppendingString:toCart];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertt
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tintColor = [UIColor blackColor];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSLog(@"Action selected: %@", action.title);
                                                         [self addToCart:item];
                                                         [swipeTableView reloadData];
                                                         [self performSelector:@selector(pullScanBool) withObject:nil];                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             NSLog(@"Action selected: %@", action.title);
                                                             [self performSelector:@selector(pullScanBool) withObject:nil];
                                                            }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (void) presentErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not a valid item"
                                                                   message:@"This barcode is not associated with a Nike item"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSLog(@"Action selected: %@", action.title);
                                                         [self performSelector:@selector(pullScanBool) withObject:nil];
                                                     }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (void)addBarcodeScannerToView:(UIView *)view sender:(id<AVCaptureMetadataOutputObjectsDelegate>)sender {
    highlightView = [[UIView alloc] init];
    highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    highlightView.layer.borderWidth = 3;
    [view addSubview:highlightView];
    
    label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, view.bounds.size.height - 80, view.bounds.size.width, 40);
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"(none)";
    [view addSubview:label];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [backButton setFrame:CGRectMake(0, view.bounds.size.height - 40, view.bounds.size.width, 40)];
    [backButton setBackgroundColor: [UIColor orangeColor]];
    [backButton setTitle:(@"Back") forState:(UIControlStateNormal)];
    [backButton.titleLabel setFont:[UIFont fontWithName:(@"Myriad Pro") size:18.0]];
    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [backButton addTarget:(self) action:@selector(pullScanBool) forControlEvents:(UIControlEventTouchUpInside)];
    [view addSubview:backButton];
    
    
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:sender queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prevLayer.frame = view.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:prevLayer];
    
    [view bringSubviewToFront:highlightView];
    [view bringSubviewToFront:label];
    [view bringSubviewToFront:backButton];
    //[view bringSubviewToFront:self.back];
}
- (void)startRecording {
    [session startRunning];
}
- (void)stopRecording {
    [session stopRunning];
}

@end
