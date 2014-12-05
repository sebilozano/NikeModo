//
//  BarcodeScannerViewController.m
//  BarCodeScanner
//
//  Created by Sebastian Lozano on 11/1/14.
//  Copyright (c) 2014 SL. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BarcodeScannerViewController.h"


@interface BarcodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
}
@end


@implementation BarcodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    [self.view bringSubviewToFront:self.back];
}
- (void)addBarcodeScannerToView:(UIView *)view sender:(id<AVCaptureMetadataOutputObjectsDelegate>)sender {
    UIView *highlightView = [[UIView alloc] init];
    highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    highlightView.layer.borderWidth = 3;
    [view addSubview:highlightView];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, view.bounds.size.height - 40, view.bounds.size.width, 40);
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"(none)";
    [view addSubview:label];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:sender queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.frame = view.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:preview];
    
    [session startRunning];
    
    [view bringSubviewToFront:highlightView];
    [view bringSubviewToFront:label];
    //[view bringSubviewToFront:self.back];
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
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            _label.text = detectionString;
            
            [self getItemData:detectionString];
            
            [_session stopRunning];
        }
        else
            _label.text = @"(none)";
    }
    
    _highlightView.frame = highlightViewRect;
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
                                                         [self dismissViewControllerAnimated:YES completion:^{
                                                             //Add to cart
                                                             
                                                         }];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSLog(@"Action selected: %@", action.title);
                                                         [self dismissViewControllerAnimated:YES completion:^{
                                                             //DO NOTHING
                                                         }];
                                                     }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) presentErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not a valid item"
                                                                   message:@"This barcode is not associated with a Nike item"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSLog(@"Action selected: %@", action.title);
                                                         
                                                         [self dismissViewControllerAnimated:YES completion:^{
                                                             //DO NOTHING
                                                         }];
                                                     }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
