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
//  PMNativeAd.m//
//  Created  on 03/07/14.

//

#import "PMNativeAd.h"
#import "PMSDKUtil.h"
#import "PMResponseParser.h"
#import "PMAdBrowser.h"
#import "PMAdResponse.h"
#import "PMCommunicator.h"
#import "PMBaseAdRequest.h"
#import "PMBaseAdRequestPrivate.h"
#import "FoundationCategories.h"
#import "PMNetworkHandler.h"
#import "PMLogger.h"

typedef void (^CompletionHandler)(void);

#define kdistanceFilter 1000

@interface PMNativeAd()<PMAdBrowserDelegate>

@property(nonatomic,strong) PMAdBrowser * browser;

@property(nonatomic,strong) PMCommunicator * serverCommunicator;

@property (nonatomic, assign) BOOL isLocationDetectionSet;
@property (nonatomic) BOOL isAutoLocationDetectionOn;

@property(nonatomic,strong) PMBaseAdRequest * adRequest;
@property(nonatomic,strong) PMAdResponse *adResponse;

@property (nonatomic, assign) BOOL impTrackersExecuted;
@property (nonatomic, assign) BOOL clickTrackersExecuted;

-(void) retrieveAd;

@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, weak) UIView* clickableView;

@property (nonatomic, assign) BOOL locationDetectionEnabled;

/*
 @method -openInAppBrowserWithURL:withViewCotroller:completionHandler
 @param -
 url - Ladning page URL
 @param -
 controller - UIViewcontroller on which browser is presented
 @param -
 handler - Completon handler
 
 */
-(void) openInAppBrowserWithURL:(NSURL *)url withViewCotroller:(UIViewController *) controller completionHandler:(CompletionHandler)handler;

@end


@implementation PMNativeAd
@synthesize delegate;

#pragma mark- deallocators

-(void) destroy
{
    [self setLocationDetectionEnabled:NO];
    self.delegate = nil;
    self.clickableView = nil;
    self.parentViewController = nil;
    self.browser.delegate=nil;
    self.browser=nil;
    self.clickableView = nil;
}

-(void) dealloc{
    
    [self destroy];
}

#pragma mark- Public APIs


-(void)loadRequest:(PMBaseAdRequest *)adRequest{
    
    if (_isLocationDetectionSet == NO) {
        [self setLocationDetectionEnabled:YES];
    }
        
    PMError * error = [adRequest validate];
    if(!error){
        
        _adRequest = adRequest;
        [self update];
        
    }else{
        
        if ([self.delegate respondsToSelector:@selector(nativeAd:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 [self.delegate nativeAd:self didFailToReceiveAdWithError:error];
             }];
        }
    }
    
}

#pragma mark - Native Ad Initializers

-(instancetype)initWithAdServer:(NSString *)adServerUrl andZone:(NSInteger )aZone{
    
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    
    self.serverCommunicator = [PMCommunicator instance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Native Ad API

// Public api for retrieving ads
-(void) update
{
    @try {

        [self retrieveAd];
    }
    @catch (NSException *exception) {
        
        // It is expected that control will never reach here . However catching any unexpected error and preventing publisher app
        // from crash due to SDK
        NSString * msg = [NSString stringWithFormat:@"Something went wrong. Please verify, Error : %@",[exception reason]];
        ErrorLog(msg);
        PMError * err = [PMError errorWithCode:kPMErrorInternalError description:msg];
        if ([self.delegate respondsToSelector:@selector(nativeAd:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 [self.delegate nativeAd:self didFailToReceiveAdWithError:err];
             }];
        }
    }
    
}

- (void)setLocationDetectionEnabled:(BOOL)enabled
{
    _isLocationDetectionSet = YES;
    _locationDetectionEnabled = enabled;
    PMSDKUtil *deviceUtil = [PMSDKUtil sharedInstance];
    if(enabled){

        [deviceUtil enableAutoLocationRetrivialForObjectId:[NSString stringWithFormat:@"%lu",(unsigned long)self.hash]  distanceFilter:kdistanceFilter desiredAccuracy:kCLLocationAccuracyThreeKilometers];
    }else{
        
        [deviceUtil disableAutoLocationRetrivialForObjectId:[NSString stringWithFormat:@"%lu",(unsigned long)self.hash]];
    }    
}

-(void)trackViewForInteractions:(UIView*)view withViewController:(UIViewController* )viewCotroller{
    
    self.clickableView = view;
    self.parentViewController = viewCotroller;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nativeAdDidClick)];
    [view addGestureRecognizer:tapGesture];
    [self sendImpressionTrackers];
}

#pragma mark - Private Networks

// Internal function to retrieve ads
-(void) retrieveAd
{
    // Setting Request formatter for Native Ad
    if (!self.serverCommunicator.rrFormatter) {
     
        [self.serverCommunicator setRrFormatter:[self.adRequest formatter]];
    }

    typeof (self) weakSelf = self;
    // Making actual native ad Request
    [self.serverCommunicator fetchAd:self.adRequest success:^(PMAdResponse *adResponse) {
        
        PMError * error = nil;
        _adResponse = adResponse;
        
        if(adResponse.error){
            
            error = adResponse.error;
            
            [weakSelf invokeDelegateBlock:^{
                
                if([weakSelf.delegate respondsToSelector:@selector(nativeAd:didFailToReceiveAdWithError:)])
                {
                    [weakSelf.delegate nativeAd:weakSelf didFailToReceiveAdWithError:error];
                }
                
            }];
            
        }else{
            
            weakSelf.impTrackersExecuted = weakSelf.clickTrackersExecuted = NO;
            [weakSelf invokeDelegateSelector:@selector(nativeAdDidRecieveAd:)];
        }
        
    } failure:^(PMError *error) {
        
        if([weakSelf.delegate respondsToSelector:@selector(nativeAd:didFailToReceiveAdWithError:)]){
            
            [weakSelf invokeDelegateBlock:^
             {
                 
                 [weakSelf.delegate nativeAd:weakSelf didFailToReceiveAdWithError:error];
                 
             }];
        }
        
    }];    
}

-(NSArray<PMNativeAssetResponse *> *)adAssetResponseArray{
    
    PMNativeAdResponse * response = _adResponse.renderable;
    return response.adAssetResponseArray;
    
}

// This helper is used for delegate methods that only take self as an argument and
// have a void return.
//
// Should NEVER pass a selector that may have a return object since the compiler/ARC
// may not know how to deal with the memory constraints on anything returned.  For
// delegate methods that expect to return something use the block method below and
// not this helper.
// Can be called from any thread.
- (void)invokeDelegateSelector:(SEL)selector
{
    if ([self.delegate respondsToSelector:selector])
    {
        [self invokeDelegateBlock:^
         {
             // Working around the warning until Apple fixes it.  As stated above
             // the delegate methods used here should have void return types.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             [self.delegate performSelector:selector withObject:self];
#pragma clang diagnostic pop
         }];
    }
}

// Can be called on any thread but if called on the non-main thread
// will block until the main thread executes the block.
- (void)invokeDelegateBlock:(dispatch_block_t)block
{
    runOnMainQueueIfNot(block);
}

-(void)nativeAdDidClick{
    
    [self postAdClickAction];
    PMNativeAdResponse * response = _adResponse.renderable;

    NSURL * url = response.landingPageURL;
    if (url) {
        
        if ([PMSDKUtil canInternalBrowserOpenURL:url] && self.useInternalBrowser)
        {
            [self openInAppBrowserWithURL:url
                        withViewCotroller:self.parentViewController
                        completionHandler:^{
                            
                        }];
            
        }else{
            [PMSDKUtil openURL:url];
        }
    }else{
        ErrorLog(@"Invalid landing page URL");
    }
}

-(void)postAdClickAction{
    
    [self sendClickTracker];
    [self invokeDelegateSelector:@selector(nativeAdDidClick:)];
    
}

-(void) sendImpressionTrackers{
    
    if(self.impTrackersExecuted){
        return;
    }
    self.impTrackersExecuted = YES;
        
    PMNativeAdResponse * response = _adResponse.renderable;

    NSArray *trackerArray= response.impressionTrackerArray;
    
    for (NSString *tracker in trackerArray) {
        
        NSURL *url = [NSURL URLWithString:tracker];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[PMNetworkHandler sharedNetworkHandler] performRequest:request success:^(NSData *data, NSURLResponse *response) {
            
            DebugLog(@"Sucessfully executed Impression Tracker URL %@",tracker);

        } failure:^(PMError *error) {
            
            ErrorLog(@"Error code: %ld, Connection Error : %@", error.code, [error description]);

        }];
    }
}

-(void) sendClickTracker{
    
    if(self.clickTrackersExecuted){
        return;
    }
    self.clickTrackersExecuted = YES;

    PMNativeAdResponse * response = _adResponse.renderable;

    NSArray *trackerArray= response.clickTrackerArray;
    for (NSString *tracker in trackerArray) {
        
            NSURL *url = [NSURL URLWithString:tracker];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
            [[PMNetworkHandler sharedNetworkHandler] performRequest:request success:^(NSData *data, NSURLResponse *response) {
                
                DebugLog(@"Sucessfully executed Click Tracker URL %@",tracker);

            } failure:^(PMError *error) {
                ErrorLog(@"Error code: %ld, Connection Error : %@", error.code, [error description]);
 
            }];
        }
}

-(void) loadInImageView:(UIImageView *)imageView withURL:(NSString *) urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[PMNetworkHandler sharedNetworkHandler] performRequest:request success:^(NSData *data, NSURLResponse *response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            imageView.image = [UIImage imageWithData:data];
        });
        
    } failure:^(PMError *error) {
        ErrorLog(@"Error code : %ld, Description %@", error.code, [error description]);
    }];
}

#pragma mark - AddOns
-(void) openInAppBrowserWithURL:(NSURL *)url withViewCotroller:(UIViewController *) controller completionHandler:(CompletionHandler)handler{
    
    self.browser = [[PMAdBrowser alloc] init];
    self.browser.delegate=self;
    __weak typeof(self) weakSelf = self;
    [controller presentViewController:self.browser animated:YES completion:^{
        [weakSelf.browser setURL:url];
        handler();
    }];
}

#pragma mark- PMBrowserDelegates

- (void)browser:(PMAdBrowser*)browser didFailLoadWithError:(PMError*)error
{
        [self.browser dismissViewControllerAnimated:YES completion:^{
            
        }];
}

- (void)browserWillLeaveApplication:(PMAdBrowser*)browser
{
    [self.browser dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)browserDidClose:(PMAdBrowser *)browser
{
    __weak typeof(self) weakSelf = self;
    [browser dismissViewControllerAnimated:YES completion:^{
        
        weakSelf.browser.delegate = nil;
        weakSelf.browser = nil;
        InfoLog(@"In-App Browser Dismissed");
        
    }];
}

@end
