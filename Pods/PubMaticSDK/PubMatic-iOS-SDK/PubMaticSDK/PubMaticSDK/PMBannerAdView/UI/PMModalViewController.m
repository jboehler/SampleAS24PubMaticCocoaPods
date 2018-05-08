/*
 
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 
 * Unpublished Copyright (c) 2006-2017 PubMatic, All Rights Reserved.
 
 *
 
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 
 * Confidentiality and Non-disclosure agreements explicitly covering such access.
 
 *
 
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 
 */

//
//  PMModalViewController.m
//   PMBannerAdView 
//
//  Created on 1/2/13.

//

#import "PMModalViewController.h"

@interface PMModalViewController ()

@property (nonatomic, assign) UIInterfaceOrientation forcedOrientation;

@end

@implementation PMModalViewController

@synthesize delegate, allowRotation;
@synthesize forcedOrientation;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.allowRotation = YES;
        self.forcedOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.allowRotation)
        return YES;
    
    if (toInterfaceOrientation == self.forcedOrientation)
        return YES;
    
    return NO;
}

- (BOOL)shouldAutorotate
{
    if (self.allowRotation)
        return YES;
    
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{

    if (self.allowRotation)
        return [[UIApplication sharedApplication] statusBarOrientation];
    
    return self.forcedOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.allowRotation)
        return UIInterfaceOrientationMaskAll;
    
    switch (self.forcedOrientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortrait;

        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscape;
            
        default:
            // Implemented to supress warnings
            break;
    }
    
    // Ideally control should never reach here
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(PMModalViewControllerDidRotate:)])
    {
        [self.delegate PMModalViewControllerDidRotate:self];
    }
}

- (void)forceRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.forcedOrientation = interfaceOrientation;
    UIViewController* presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^
     {
         [presentingController presentViewController:self animated:YES completion:^{
             
         }];
     }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
