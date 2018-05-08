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
//   PMBannerAdView 
//
//  Created on 9/21/12.

//

#import "PMBannerAdDefaults.h"
#import "PMBannerAdView.h"
#import "UIWebView+PMBannerAdView.h"
#import "PMMRAIDBridge.h"
#import "PMAdDescriptor.h"
#import "PMAdBrowser.h"
#import "PMModalViewController.h"
#import "PMSDKUtil.h"

#import "PMCloseButtonPNG.h"

#import "PMCommunicator.h"
#import "PMLogger.h"
#import "PMBaseAdRequestPrivate.h"
#import "FoundationCategories.h"
#import "PMNetworkHandler.h"

#define CALENDAR_USAGE_DESC_KEY @"NSCalendarsUsageDescription"
#define PHOTO_LIB_USAGE_DESC_KEY @"NSPhotoLibraryUsageDescription"

#define kdistanceFilter 1000

/** Ad placement type.
 */
typedef NS_ENUM(NSInteger, PMAdViewPlacementType) {
    
    /* Ad is placed in application content.
     */
    
    PMAdViewPlacementInline = 0,
    
    /*Ad is placed over and in the way of application content.
     Generally used to place an ad between transtions in an application
     and consumes the entire screen.
     */
    
    PMAdViewPlacementInterstitial,
};


@interface PMBannerAdView() <UIGestureRecognizerDelegate, UIWebViewDelegate, PMMRAIDBridgeDelegate,
    PMAdBrowserDelegate, PMModalViewControllerDelegate, EKEventEditViewDelegate>

@property (nonatomic, strong) NSURLSessionTask* twoPartAdFetchTask;

// Ad fetching
// Update timer
@property (nonatomic, strong) NSTimer* updateTimer;

// Set to skip the next timer update
@property (nonatomic, assign) BOOL skipNextUpdateTick;

// Set to indicate an update should occur after user interaction is done.
@property (nonatomic, assign) BOOL deferredUpdate;

// Interstitial delay timer
@property (nonatomic, strong) NSTimer* interstitialTimer;

// Close button
@property (nonatomic, assign) NSTimeInterval closeButtonTimeInterval;
@property (nonatomic, strong) NSTimer* closeButtonTimer;
@property (nonatomic, strong) UIButton* closeButton;

// Descriptor of active ad
@property (nonatomic, strong) PMAdDescriptor* adDescriptor;

// MRAID 2.0
@property (nonatomic, strong) PMMRAIDBridge* mraidBridge;

// Internal Browser
@property (nonatomic, strong) PMAdBrowser* adBrowser;

// Used to render interstitial, expand and internal browser.
@property (nonatomic, strong) PMModalViewController* modalViewController;

// If for some reason the modal needs to be dismissed before the presentation is complete, this flag is set.
@property (nonatomic, assign) BOOL modalDismissAfterPresent;

// Used to track state of the status bar prior to modal view.
//@property (nonatomic, assign) BOOL statusBarHidden;

// Determines if this ad is an expand URL ad.
@property (nonatomic, assign) BOOL isExpandedURL;

// Two-part expand properties for initialization.
@property (nonatomic, strong) PMMRAIDExpandProperties* twoPartExapandProperties;

// Used to display MRAID expand URL.
@property (nonatomic, strong)  PMBannerAdView * expandedAdView;

// Used to track if if tracking is needed for the ad descriptor.
@property (nonatomic, assign) BOOL impTrackersExecuted;
@property (nonatomic, assign) BOOL clickTrackersExecuted;

@property(nonatomic,strong) PMCommunicator * serverCommunicator;

@property(nonatomic,strong) PMBaseAdRequest * adRequest;

@property(nonatomic,strong) PMAdResponse *adResponse;
@property (nonatomic, assign) BOOL isLocationDetectionSet;
@property (nonatomic, assign) BOOL locationDetectionEnabled;

@property (nonatomic) UIView* expandView;
@property (nonatomic) UIView* resizeView;
@property (nonatomic) UIWebView* webView;
@property (nonatomic, readonly) PMAdViewPlacementType placementType;

// Using the rootViewController, determines the view that the resizeView uses as a superview.
- (UIView*)resizeViewSuperview;

// Invokes ad tracking as needed.
- (void)performAdTracking;

@end


@implementation  PMBannerAdView

#pragma mark- Public APIs

-(void)loadRequest:(PMBaseAdRequest *)adRequest{
        
    if (_isLocationDetectionSet == NO) {
        [self setLocationDetectionEnabled:YES];
    }

    PMError * error = [adRequest validate];

    if (!adRequest) {
     
        error = [PMError errorWithCode:kPMErrorInvalidRequest description:@"Ad Request can not be nil"];
    }
    
    if(!error){

        _adRequest = adRequest;
        @try
        {
            [self update];
        }
        @catch (NSException *exception)
        {
            NSString * msg = [NSString stringWithFormat:@"Something went wrong. Please verify, Error : %@",[exception reason]];
            ErrorLog(msg);
            PMError * err = [PMError errorWithCode:kPMErrorInternalError description:msg];
            if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
            {
                [self invokeDelegateBlock:^
                 {
                     [self.delegate bannerAdView:self didFailToReceiveAdWithError:err];
                 }];
            }
        }

    }else{
        
        ErrorLog(@"Error code: %ld Description: %@", error.code, error.localizedDescription);

        if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 [self.delegate bannerAdView:self didFailToReceiveAdWithError:error];
             }];
        }
        
    }
}

#pragma mark-

-(void)setUpdateInterval:(NSTimeInterval)updateInterval{
    
    if(updateInterval>=120){
        
        updateInterval = 120;
        
    }else if(updateInterval>12){
        
        //No change
        
    }else if(updateInterval>0){
        
        updateInterval = 12;

    }else{
        
        updateInterval = 0;
    }
    _updateInterval = updateInterval;
}

#pragma mark -

- (void)dealloc
{

    [_twoPartAdFetchTask cancel];
    _twoPartAdFetchTask = nil;
    [_closeButtonTimer invalidate];
    _closeButtonTimer = nil;
    [_updateTimer invalidate];
    _updateTimer = nil;
    [_interstitialTimer invalidate];
    _interstitialTimer = nil;

    [self reset];
    
    [_mraidBridge setDelegate:nil];
    _mraidBridge = nil;

    [_webView setDelegate:nil];
    [_webView stopLoading];
    _webView = nil;
}

#pragma markv - Init

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initInterstitial
{
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        _placementType = PMAdViewPlacementInterstitial;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizesSubviews = YES;
        _placementType = PMAdViewPlacementInline;
        self.closeButtonTimeInterval = -1;
        self.serverCommunicator = [PMCommunicator instance];
    }
    return self;
}

#pragma mark - Update

- (void)internalUpdate
{
    self.deferredUpdate = NO;
    
    // Don't update if the internal browser is up.
    if ([self adBrowserOpen])
    {
        self.deferredUpdate = YES;
        return;
    }
    
    // Don't update if an MRAID ad is expanded or resized.
    switch ([self.mraidBridge state])
    {
        case PMMRAIDBridgeStateLoading:
        case PMMRAIDBridgeStateDefault:
        case PMMRAIDBridgeStateHidden:
            break;
            
        case PMMRAIDBridgeStateExpanded:
        case PMMRAIDBridgeStateResized:
            self.deferredUpdate = YES;
            return;
    }
    
    CGSize size = self.bounds.size;
    
    if (self.placementType == PMAdViewPlacementInterstitial)
    {
        size = [UIScreen mainScreen].bounds.size;
    }
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat effectiveWidth = size.width * scale;
    CGFloat effectiveHeight = size.height * scale;
    
    [self.adRequest.extraInfoDictionary setObject:[NSString stringWithFormat:@"%d", (int)effectiveWidth] forKey:@"ad_width"];
    [self.adRequest.extraInfoDictionary setObject:[NSString stringWithFormat:@"%d", (int)effectiveHeight]
                                            forKey:@"ad_height"];
    [self constructAdRequest];
}

-(void)constructAdRequest{
    
    if (!self.serverCommunicator.rrFormatter) {
        [self.serverCommunicator setRrFormatter:[self.adRequest formatter]];
    }

    __weak typeof (self) weakSelf = self;
    [self.serverCommunicator fetchAd:self.adRequest success:^(PMAdResponse *adResponse) {
        
        _adResponse = adResponse;
        if(adResponse.error){
            
            if ([weakSelf.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
            {
             
                [weakSelf invokeDelegateBlock:^
                 {
                     [weakSelf.delegate bannerAdView:weakSelf didFailToReceiveAdWithError:adResponse.error];
                 }];
            }
            
        }else{
            
            PMAdDescriptor * ad = adResponse.renderable;
            [weakSelf renderWithAdDescriptor:ad];
        }
        
    } failure:^(PMError *error) {
       
        if ([weakSelf.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
        {
         
            [weakSelf invokeDelegateBlock:^
             {
                 [weakSelf.delegate bannerAdView:weakSelf didFailToReceiveAdWithError:error];
             }];

        }
    }];
}

-(BOOL)adVisible{
    
    CGRect currentFrame = [self absoluteFrameForView:self.webView];
    CGSize maxSize = [self resizeViewMaxRect].size;
    
    BOOL viewable = NO;
    
    if (self.placementType == PMAdViewPlacementInline)
    {
        if (self.mraidBridge.state == PMMRAIDBridgeStateExpanded)
        {
            // This doesn't take any consideration to the app being suspended (and obviously terminated).
            viewable = YES;
        }
        else
        {
            if (self.window != nil)
            {
                if (self.hidden == NO)
                {
                    if (CGRectIntersectsRect(CGRectMake(0, 0, maxSize.width, maxSize.height), currentFrame))
                    {
                        viewable = YES;
                    }
                }
            }
        }
    }else
    {
        
        if (self.modalViewController.view.superview != nil)
        {
            viewable = YES;
        }
    }
    
    if ([self adBrowserOpen])
    {
        // When the browser is up, it's modal and even expanded ads are covered.
        viewable = NO;
    }
    return viewable;
}

- (void)internalUpdateTimerTick
{
    if (![self adVisible] || ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive))
        return;
    
    if (self.skipNextUpdateTick){
        self.skipNextUpdateTick = NO;
        return;
    }
    
    [self internalUpdate];
}

- (void)update
{
   [self update:NO];
}

- (void)update:(BOOL)force
{
    // Determine if the calendar can be used and ask user for authorization if necessary.

    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
    }
    
    
    if (force)
    {
        // Close the ad browser if open.
        if ([self adBrowserOpen])
        {
            [self closeAdBrowser];
        }
        
        // Close interstitial if interstitial.
        [self closeInterstitial];
        
        // Do non-interstitial cleanup after this.
        if (self.placementType == PMAdViewPlacementInline)
        {
            // Close any expanded or resized MRAID ad.
            switch ([self.mraidBridge state])
            {
                case PMMRAIDBridgeStateLoading:
                case PMMRAIDBridgeStateDefault:
                case PMMRAIDBridgeStateHidden:
                    break;
                    
                case PMMRAIDBridgeStateExpanded:
                case PMMRAIDBridgeStateResized:
                    [self mraidBridgeClose:self.mraidBridge];
                    break;
            }
        }
    }
    
    [self internalUpdate];
    
    if(self.updateInterval){
        typeof (self) weakSelf = self;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:weakSelf selector:@selector(internalUpdateTimerTick) userInfo:nil repeats:YES];
    }
}

- (void)reset
{
    self.delegate = nil;
    self.deferredUpdate = NO;
    self.serverCommunicator = nil;
    
    // Close the ad browser if open.
    if ([self adBrowserOpen])
    {
        [self closeAdBrowser];
    }
    
    [self.closeButtonTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
    self.closeButtonTimer = nil;

    // Close interstitial if interstitial.
    [self closeInterstitial];
    
    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
    }
    
    // Stop location detection
    [self setLocationDetectionEnabled:NO];
    
    // Do non-interstitial cleanup after this.
    if (self.placementType != PMAdViewPlacementInline)
        return;
    
    // Close any expanded or resized MRAID ad.
    switch ([self.mraidBridge state])
    {
        case PMMRAIDBridgeStateLoading:
        case PMMRAIDBridgeStateDefault:
        case PMMRAIDBridgeStateHidden:
            break;
            
        case PMMRAIDBridgeStateExpanded:
        case PMMRAIDBridgeStateResized:
            [self mraidBridgeClose:self.mraidBridge];
            break;
    }
    
    [self resetWebAd];
}

- (void)removeContent
{
    self.deferredUpdate = NO;
    
    [self closeInterstitial];
    
    // Do non-interstitial cleanup after this.
    if (self.placementType != PMAdViewPlacementInline)
        return;
    
    // Close any expanded or resized MRAID ad.
    switch ([self.mraidBridge state])
    {
        case PMMRAIDBridgeStateLoading:
        case PMMRAIDBridgeStateDefault:
        case PMMRAIDBridgeStateHidden:
            break;
            
        case PMMRAIDBridgeStateExpanded:
        case PMMRAIDBridgeStateResized:
            [self mraidBridgeClose:self.mraidBridge];
            break;
    }
    
    [self resetWebAd];
}

- (void)resumeUpdates
{
    if (self.deferredUpdate)
    {
        [self update];
    }
    
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) 
                                           withObject:nil
                                        waitUntilDone:YES];
        
        typeof (self) weakSelf = self;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateTimer.timeInterval target:weakSelf selector:@selector(internalUpdate) userInfo:nil repeats:YES];

        
    }
}


#pragma mark - Two Creative Expand

- (void)showExpanded:(NSString*)url withExpandProperties:(PMMRAIDExpandProperties*)ep
{
    self.isExpandedURL = YES;
    self.twoPartExapandProperties = ep;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeoutInterval:PM_DEFAULT_NETWORK_TIMEOUT];
    typeof (self) weakSelf = self;
    runOnMainQueueIfNot(^{
        
        [weakSelf renderMRAIDAd:request andFireTrackers:NO];
    });
}

#pragma mark - Interstitial

- (void)showInterstitial
{
    [self showInterstitialForDuration:0];
}

- (void)showInterstitialForDuration:(NSTimeInterval)delay
{
    if (self.impTrackersExecuted) {
        return;
    }
    
    if (self.placementType != PMAdViewPlacementInterstitial)
        return;
    
    // If modalViewController is already presented for instl, return.
    if (self.modalViewController.view.superview != nil)
        return;
    
    [self presentModalView:self.expandView];
    
    [self performAdTracking];
    
    if ((self.mraidBridge != nil) && (self.webView.isLoading == NO))
    {
        [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateDefault];
        [self.mraidBridge setState:PMMRAIDBridgeStateDefault forWebView:self.webView];
    }
    
    [self prepareCloseButton];
    
    // Cancel the interstitial timer.
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
    }

    if(delay > 0){
        
        typeof (self) weakSelf = self;
        self.interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:weakSelf selector:@selector(closeInterstitial) userInfo:nil repeats:NO];
    }
}

- (void)closeInterstitial
{
    // Cancel the interstitial timer.
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
    }
    
    if (self.placementType != PMAdViewPlacementInterstitial)
        return;
    
    if (self.modalViewController.view.superview == nil)
        return;
    
    [self dismissModalView:self.expandView animated:YES];
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateHidden];
        [self.mraidBridge setState:PMMRAIDBridgeStateHidden forWebView:self.webView];
    }
}

#pragma mark - URL handling (ad clicks, browser links, etc..)

// returns YES if opened (external or internal), NO if not
- (BOOL)openURLString:(NSString *)urlString
{
    NSURL* nsurl = [NSURL URLWithString:urlString];
    [self performClickTracking];
    BOOL canOpenInternal = [PMSDKUtil canInternalBrowserOpenURL:nsurl];
    
    __block BOOL shouldOpen = YES;
    if ([self.delegate respondsToSelector:@selector(bannerAdView:shouldOpenURL:)])
    {
        [self invokeDelegateBlock:^
         {
             shouldOpen = [self.delegate bannerAdView:self shouldOpenURL:nsurl];
         }];
    }
    
    if (shouldOpen == NO)
        return NO;
    
    if (canOpenInternal && self.useInternalBrowser)
    {
        [self openAdBrowserWithURL:nsurl];
        return NO;
    }
    
    [self invokeDelegateSelector:@selector(bannerAdViewWillLeaveApplication:)];
    
    self.skipNextUpdateTick = YES;
    
    [PMSDKUtil openURL:nsurl];
    return YES;
}

#pragma mark - Internal Browser

- (BOOL)isInternalBrowserOpen
{
    return [self adBrowserOpen];
}

- (PMAdBrowser*)adBrowser
{
    if (_adBrowser == nil)
    {
        _adBrowser = [PMAdBrowser new];
        _adBrowser.delegate = self;
    }
    
    return _adBrowser;
}

- (BOOL)adBrowserOpen
{
    if (_adBrowser == nil)
        return NO;
    
    if (_adBrowser.view.superview == nil)
        return NO;
    
    return YES;
}

- (void)openAdBrowserWithURL:(NSURL*)url
{
    self.adBrowser.view.frame = self.modalViewController.view.bounds;
    
    self.adBrowser.URL = url;
    
    [self invokeDelegateSelector:@selector(bannerAdViewInternalBrowserWillOpen:)];
    
    [self presentModalView:self.adBrowser.view];
    
    [self invokeDelegateSelector:@selector(bannerAdViewInternalBrowserDidOpen:)];
}

- (void)closeAdBrowser
{
    [self invokeDelegateSelector:@selector(bannerAdViewInternalBrowserWillClose:)];
    
    [self dismissModalView:self.adBrowser.view animated:YES];
    self.adBrowser = nil;

    [self resumeUpdates];
    
    [self invokeDelegateSelector:@selector(bannerAdViewInternalBrowserDidClose:)];
}

- (void)browser:(PMAdBrowser *)browser didFailLoadWithError:(PMError *)error
{
    ErrorLog(@"Error code: %ld \nInternal browser unable to load content. Reason: %@", error.code, [error description]);
    
}

- (void)browserDidClose:(PMAdBrowser *)browser
{
    // Delay to workaround issues with iOS5 not implementing isBeingPresented
    // as expected (and as-is in iOS6).
    [self performSelector:@selector(closeAdBrowser) withObject:nil afterDelay:0.5];
}

- (void)browserWillLeaveApplication:(PMAdBrowser*)browser
{
    [self invokeDelegateSelector:@selector(bannerAdViewWillLeaveApplication:)];
    
    self.skipNextUpdateTick = YES;
    
    // Delay to workaround issues with iOS5 not implementing isBeingPresented
    // as expected (and as-is in iOS6).
    [self performSelector:@selector(closeAdBrowser) withObject:nil afterDelay:0.5];
}

#pragma mark - Window containers

- (UIViewController*)modalViewController
{
    if (_modalViewController == nil)
    {
        _modalViewController = [PMModalViewController new];
        _modalViewController.delegate = self;
    }
    
    return _modalViewController;
}

- (void)presentModalView:(UIView*)view
{
    [self.modalViewController.view addSubview:view];
    
    if (self.modalViewController.view.superview == nil)
    {
        
        UIViewController* rootViewController = [self modalRootViewController];
        
        if (rootViewController == nil)
        {
            ErrorLog(@"Unable to present modal view controller becuase rootViewController is nil.  Be sure to set the keyWindow's rootViewController or provide one with PMBannerAdViewPResentionController:.");

            return;
        }
        
        if ([rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            self.modalDismissAfterPresent = NO;
            
            [rootViewController presentViewController:self.modalViewController animated:YES completion:^()
            {
                if (self.modalDismissAfterPresent)
                {
                    [self dismissModalView:view animated:YES];
                }
            }];
        }
        else
        {
            [rootViewController presentViewController:self.modalViewController animated:YES completion:^{
                
            }];
        }
    }
}

- (void)dismissModalView:(UIView*)view animated:(BOOL)animated
{
    if (self.modalViewController.view.superview == nil)
        return;
    
    if ([self.modalViewController respondsToSelector:@selector(isBeingPresented)])
    {
        if ([self.modalViewController isBeingPresented])
        {
            self.modalDismissAfterPresent = YES;
            return;
        }
    }
    
    if ([view superview] == self.modalViewController.view)
        [view removeFromSuperview];
    
    if ([self.modalViewController.view.subviews count] > 0)
        return;
        
    if ([self.modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self.modalViewController dismissViewControllerAnimated:animated completion:nil];
    }
    else
    {
        [self.modalViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (UIViewController*)modalRootViewController
{
    UIViewController* rootViewController = [self.window rootViewController];
    
    if (rootViewController == nil)
    {
        rootViewController = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
    }
    
    if (rootViewController == nil)
    {
        rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(bannerAdViewPresentationController:)])
    {
        UIViewController * publisherProvidedVC = [self.delegate bannerAdViewPresentationController:self];
        //Check if publisher provided UIViewcontroller is currently on app controller stack
        if (publisherProvidedVC.parentViewController) {
            rootViewController = publisherProvidedVC;
        }
    }
    
    if (rootViewController && rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }

    return rootViewController;
}

#pragma mark - PMModalViewControllerDelegate

- (void)PMModalViewControllerDidRotate:(PMModalViewController*)controller
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSInteger degrees = 0;
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            degrees = 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            degrees = -90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            degrees = 90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            degrees = 180;
            break;
            
        default:
            // Implemented to supress warnings
            break;
            
    }
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
}

#pragma mark - Native containers

- (UIWebView*)webView
{
    if (_webView == nil)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.autoresizesSubviews = YES;
        _webView.mediaPlaybackRequiresUserAction = NO;
        _webView.allowsInlineMediaPlayback = YES;
    }
    
    return _webView;
}

- (UIView*)expandView
{
    if (_expandView == nil)
    {
        _expandView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _expandView.autoresizesSubviews = YES;
        _expandView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _expandView.backgroundColor = [UIColor whiteColor];
        _expandView.opaque = YES;
        _expandView.userInteractionEnabled = YES;
    }
    
    return _expandView;
}

- (UIView*)resizeView
{
    if (_resizeView == nil)
    {
        _resizeView = [[UIView alloc] initWithFrame:CGRectZero];
        _resizeView.backgroundColor = [UIColor clearColor];
        _resizeView.opaque = NO;
        _resizeView.autoresizesSubviews = YES;
        _resizeView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    return _resizeView;
}

#pragma mark - Resize View Container

- (UIView*)resizeViewSuperview
{
    UIView* resizeViewSuperview = nil;
    if ([self.delegate respondsToSelector:@selector(bannerAdViewResizeSuperview:)])
    {
        resizeViewSuperview = [self.delegate bannerAdViewResizeSuperview:self];
    }
    
    if (!resizeViewSuperview) {
        UIViewController * rootViewController = [[self window] rootViewController];
        if (!rootViewController) {
            rootViewController = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
            
            if (!rootViewController) {
                rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            }
        }
        UIViewController * effectiveParentVC = rootViewController;
        if (effectiveParentVC.presentedViewController) {
            effectiveParentVC = effectiveParentVC.presentedViewController;
        }
        resizeViewSuperview = [effectiveParentVC view];
    }
    return resizeViewSuperview;
}

- (CGRect)resizeViewMaxRect
{
    CGSize screenSize = [self screenSizeIncludingStatusBar:YES];
    CGRect maxRect = [self resizeViewSuperview].bounds;
    
    // Only account for the status bar size if the maxSize is the screen size.
    // This would be the case where the resize superview is the rootViewController's
    // view or the like.  It also works around the case where the resize superview may
    // be this view's superview which may already account for the status bar.
    
    if (CGSizeEqualToSize(maxRect.size, screenSize))
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        if (CGRectEqualToRect(statusBarFrame, CGRectZero) == NO)
        {
            maxRect.origin.y += statusBarFrame.size.height;
            maxRect.size.height -= statusBarFrame.size.height;

        }
    }
    
    return maxRect;
}

#pragma mark - Close Button

- (void)showCloseButtonAfterDelay:(NSTimeInterval)delay
{
    self.closeButtonTimeInterval = delay;    
}

- (void)prepareCloseButton
{
    if (self.closeButtonTimer.isValid) {
        return;
    }
    
    if (self.closeButton.superview) {
        [self.closeButton removeFromSuperview];
    }
    
    if(self.closeButtonTimeInterval > 0){
        typeof (self) weakSelf = self;
        self.closeButtonTimer = [NSTimer scheduledTimerWithTimeInterval:self.closeButtonTimeInterval
                                                                 target:weakSelf selector:@selector(showCloseButton)
                                                               userInfo:nil repeats:NO];
        return;
    }

    if (self.mraidBridge != nil)
    {

        switch (self.mraidBridge.state)
        {
            case PMMRAIDBridgeStateDefault:
                if (self.placementType == PMMRAIDBridgePlacementTypeInterstitial)
                {

                    if (self.mraidBridge.expandProperties.useCustomClose == NO)
                    {

                        [self showCloseButton];
                    }
                }
                break;
                
            case PMMRAIDBridgeStateExpanded:{
                
                if (self.twoPartExapandProperties) {
                    
                    // When expanded use the built in button or the custom one, else nothing else. for two part ad
                    if (self.twoPartExapandProperties.useCustomClose == NO)
                    {
                        [self showCloseButton];
                    }
                    
                }else{
                    
                    // When expanded use the built in button or the custom one, else nothing else.
                    if (self.mraidBridge.expandProperties.useCustomClose == NO)
                    {
                        [self showCloseButton];
                    }
                }
               
            }
                return;
                
            case PMMRAIDBridgeStateResized:
                // The ad creative MUST supply it's own close button.
                return;
                
            default:
                break;
        }
    }
    
}

- (void)showCloseButton{
    
    CGPoint position = CGPointMake(CGRectGetWidth(self.expandView.frame) - CGRectGetWidth(self.closeButton.frame), 0);
    [self showCloseButtonAtPosition:position onView:self.expandView];
}

- (void)showCloseButtonAtPosition:(CGPoint)position onView:(UIView *)parentView
{
   
    CGRect closeBtnFrame = self.closeButton.frame;
    closeBtnFrame.origin = position;
    self.closeButton.frame = closeBtnFrame;
    
    if (self.mraidBridge != nil)
    {
        switch (self.mraidBridge.state)
        {
            case PMMRAIDBridgeStateLoading:
            case PMMRAIDBridgeStateDefault:
            case PMMRAIDBridgeStateHidden:
                // Like text or image ads just put the close button at the top of the stack
                // on the ad view and not on the webview.
                break;
                
            case PMMRAIDBridgeStateExpanded:
                [parentView addSubview:self.closeButton];
                [parentView bringSubviewToFront:self.closeButton];
                return;
                
            case PMMRAIDBridgeStateResized:
                [parentView addSubview:self.closeButton];
                [parentView bringSubviewToFront:self.closeButton];
                return;
        }
    }
    
    switch (self.placementType)
    {
        case PMAdViewPlacementInline:
        {
            // Place in top right.
            [parentView addSubview:self.closeButton];
            [parentView bringSubviewToFront:self.closeButton];
            break;
        }
            
        case PMAdViewPlacementInterstitial:
        {
            // Place in top right.
            [parentView addSubview:self.closeButton];
            [parentView bringSubviewToFront:self.closeButton];
            break;
        }
    }
}

#pragma mark - Control Handling

- (UIButton*)closeButton
{
    if (!_closeButton)
    {
        __block UIButton* customBtn = nil;
        CGRect closeControlFrame = CGRectMake(0, 0, 50, 50);

        if ([self.delegate respondsToSelector:@selector(bannerAdViewCustomCloseButton:)])
        {
            [self invokeDelegateBlock:^
             {
                 customBtn = [self.delegate bannerAdViewCustomCloseButton:self];
             }];
        }
        
        if (customBtn) {
            _closeButton = customBtn;
            [_closeButton setFrame:closeControlFrame];
        }else{
            
            _closeButton = [[UIButton alloc] initWithFrame:closeControlFrame];
            NSData* buttonData = [NSData dataWithBytesNoCopy:PMCloseButton_png
                                                      length:PMCloseButton_png_len
                                                freeWhenDone:NO];
            
            UIImage* buttonImage = [UIImage imageWithData:buttonData];
            [_closeButton setImage:buttonImage forState:UIControlStateNormal];
        }
        
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.opaque = NO;

        [_closeButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_closeButton addTarget:self
                        action:@selector(closeControlEvent:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)closeControlEvent:(id)sender
{
    if (self.mraidBridge != nil)
    {
        switch (self.mraidBridge.state)
        {
            case PMMRAIDBridgeStateLoading:
            case PMMRAIDBridgeStateDefault:
            case PMMRAIDBridgeStateHidden:
                // In these states this event should never ever occur, however let
                // control drop through so that the delegate can be invoked.
                break;

            case PMMRAIDBridgeStateExpanded:
            case PMMRAIDBridgeStateResized:
                // Handle as if the close request came from the mraid bridge.
                [self mraidBridgeClose:self.mraidBridge];
                
                // Nothing else to do here and don't send the event to the
                // delegate below.
                return;
        }
    }
    
    // If it's not MRAID then nothing to do but notify the delegate.
    [self invokeDelegateSelector:@selector(bannerAdViewCloseButtonPressed:)];
}

#pragma mark - Resetting

- (void)resetWebAd
{
    [self.mraidBridge setDelegate:nil];
    self.mraidBridge = nil;
    
    [self.webView removeFromSuperview];
    [self.webView stopLoading];
}

#pragma mark - MRAID Ad Handling

// Main thread
- (void)renderMRAIDAd:(id)mraidFragmentOrTwoPartRequest andFireTrackers:(BOOL)shouldFire{
    
    [self.webView stopLoading];

    self.mraidBridge = [PMMRAIDBridge new];
    self.mraidBridge.delegate = self;
    switch (self.placementType)
    {
        case PMAdViewPlacementInline:
            if (![self.webView.superview isEqual:self]) {
                [self addSubview:self.webView];
            }
            break;
            
        case PMAdViewPlacementInterstitial:
            self.webView.frame = self.expandView.bounds;
            [self.expandView addSubview:self.webView];
            break;
    }
    
    if (self.isExpandedURL == NO)
    {
        NSString* htmlContent = [NSString stringWithFormat:PM_RICHMEDIA_FORMAT_WITHMRAIDJS, (NSString*)mraidFragmentOrTwoPartRequest];
        [self.webView loadHTMLString:htmlContent baseURL:self.adRequest.hostURL];
    }
    else
    {
        NSURLRequest * request = (NSURLRequest*)mraidFragmentOrTwoPartRequest;
        __weak typeof(self) weakSelf = self;
        if (self.twoPartAdFetchTask) {
            [self.twoPartAdFetchTask cancel];
        }
        self.twoPartAdFetchTask = [[PMNetworkHandler sharedNetworkHandler] performRequest:request success:^(NSData *data, NSURLResponse *response) {
            
            NSString * adHtml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            runOnMainQueueIfNot(^{
                
                NSString* htmlContent = [NSString stringWithFormat:PM_RICHMEDIA_FORMAT_WITHMRAIDJS,adHtml];
                [weakSelf.webView loadHTMLString:htmlContent baseURL:request.URL];
                [weakSelf mraidBridge:weakSelf.mraidBridge expandWithURL:nil];
                
            });
        } failure:^(PMError *error) {
            
            ErrorLog(@"Erro code:%ld Faied to load two part ad : %@", error.code, [error localizedDescription]);
        }];
    }
    
    if (shouldFire) {
        [self performAdTracking];
    }
    [self invokeDelegateSelector:@selector(bannerAdViewDidRecieveAd:)];
}

// UIWebView callback thread
- (void)mraidSupports:(UIWebView*)wv
{
    // SMS defaults to availability if developer doesn't implement check.
    __block BOOL smsAvailable = [MFMessageComposeViewController canSendText];
    if (smsAvailable && [self.delegate respondsToSelector:@selector(bannerAdViewSupportsSMS:)])
    {
        [self invokeDelegateBlock:^
        {
             smsAvailable = [self.delegate bannerAdViewSupportsSMS:self];
        }];
    }
    
    // Phone defaults to availability if developer doesn't implement check.
    __block BOOL phoneAvailable = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]];
    if (phoneAvailable && [self.delegate respondsToSelector:@selector(bannerAdViewSupportsPhone:)])
    {
        [self invokeDelegateBlock:^
        {
            phoneAvailable = [self.delegate bannerAdViewSupportsPhone:self];
        }];
    }
    
    // Calendar defaults to disabled if check not implemented by developer.
    __block BOOL calendarAvailable = NO;
    if ([self.delegate respondsToSelector:@selector(bannerAdViewSupportsCalendar:)])
    {
        [self invokeDelegateBlock:^
         {
             calendarAvailable = [self.delegate bannerAdViewSupportsCalendar:self];
         }];
    }
    
    // Store picture defaults to disabled if check not implemented by developer.
    __block BOOL storePictureAvailable = [self.delegate respondsToSelector:@selector(bannerAdViewSupportsStorePicture:)];
    if (storePictureAvailable)
    {
        [self invokeDelegateBlock:^
        {
            storePictureAvailable = [self.delegate bannerAdViewSupportsStorePicture:self];
        }];
    }
    
    [self.mraidBridge setSupported:smsAvailable forFeature:PMMRAIDBridgeSupportsSMS forWebView:wv];
    [self.mraidBridge setSupported:phoneAvailable forFeature:PMMRAIDBridgeSupportsTel forWebView:wv];
    [self.mraidBridge setSupported:calendarAvailable forFeature:PMMRAIDBridgeSupportsCalendar forWebView:wv];
    [self.mraidBridge setSupported:storePictureAvailable forFeature:PMMRAIDBridgeSupportsStorePicture forWebView:wv];
    [self.mraidBridge setSupported:YES forFeature:PMMRAIDBridgeSupportsInlineVideo forWebView:wv];
}

- (void)mraidInitializeBridge:(PMMRAIDBridge*)bridge forWebView:(UIWebView*)wv
{
    @synchronized (bridge)
    {
        if (bridge.needsInit == NO)
            return;
        
        if (wv.isLoading)
            return;
        
        bridge.needsInit = NO;
    }
    
    [self mraidSupports:self.webView];
    
    PMMRAIDBridgePlacementType mraidPlacementType = PMMRAIDBridgePlacementTypeInline;
    if (self.placementType == PMAdViewPlacementInterstitial)
    {
        mraidPlacementType = PMMRAIDBridgePlacementTypeInterstitial;
    }
    [bridge setPlacementType:mraidPlacementType forWebView:self.webView];
    
    CGSize screenSize = [self screenSizeIncludingStatusBar:YES];
    
    if (self.twoPartExapandProperties == nil)
    {
        PMMRAIDExpandProperties* expandProperties = [[PMMRAIDExpandProperties alloc] initWithSize:screenSize];
        [bridge setExpandProperties:expandProperties forWebView:self.webView];
    }
    else
    {
        [bridge setExpandProperties:self.twoPartExapandProperties forWebView:self.webView];
    }
    
    PMMRAIDResizeProperties* resizeProperties = [PMMRAIDResizeProperties new];
    [bridge setResizeProperties:resizeProperties forWebView:self.webView];
    
    PMMRAIDOrientationProperties* orientationProperties = [PMMRAIDOrientationProperties new];
    [bridge setOrientationProperties:orientationProperties forWebView:self.webView];
    
    if (self.isExpandedURL == NO)
    {
        switch (self.placementType)
        {
            case PMAdViewPlacementInline:
                [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateDefault];
                break;
                
            case PMAdViewPlacementInterstitial:
                [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateExpanded];
                break;
        }
        [self.mraidBridge setState:PMMRAIDBridgeStateDefault forWebView:self.webView];
    }
    else
    {
        [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateExpanded];
        [self.mraidBridge setState:PMMRAIDBridgeStateExpanded forWebView:self.webView];
    }
    
    [bridge sendReadyForWebView:self.webView];
    
}

- (void)mraidUpdateLayoutForNewState:(PMMRAIDBridgeState)state
{
    CGSize screenSize = [self screenSizeIncludingStatusBar:YES];
    CGRect defaultFrame = [self absoluteFrameForView:self];
    CGRect currentFrame = [self absoluteFrameForView:self.webView];
    
    CGSize maxSize = [self resizeViewMaxRect].size;
    
    BOOL viewable = [self adVisible];
    maxSize = screenSize;
    defaultFrame = CGRectMake(0, 0, maxSize.width, maxSize.height);
    currentFrame = CGRectZero;
    
    if (self.modalViewController.view.superview != nil)
    {
        currentFrame = [self absoluteFrameForView:self.webView];
    }
    
    [self.mraidBridge setScreenSize:screenSize forWebView:self.webView];
    [self.mraidBridge setMaxSize:maxSize forWebView:self.webView];
    [self.mraidBridge setDefaultPosition:defaultFrame forWebView:self.webView];
    [self.mraidBridge setCurrentPosition:currentFrame forWebView:self.webView];
    [self.mraidBridge setViewable:viewable forWebView:self.webView];
}

#pragma mark - PMMRAIDBridgeDelegate

- (void)mraidBridgeInit:(PMMRAIDBridge *)bridge
{
    bridge.needsInit = YES;
    [self mraidInitializeBridge:bridge forWebView:self.webView];
}

- (void)mraidBridgeClose:(PMMRAIDBridge*)bridge
{
    if (self.placementType == PMAdViewPlacementInterstitial)
    {
        [self invokeDelegateSelector:@selector(bannerAdViewCloseButtonPressed:)];
        return;
    }
        
    switch (bridge.state)
    {
        case PMMRAIDBridgeStateLoading:
        case PMMRAIDBridgeStateHidden:
            // Nothing to close.
            return;
            
        case PMMRAIDBridgeStateDefault:
            // MRAID leaves this open ended on the SDK so ignoring the request.
            break;
            
        case PMMRAIDBridgeStateExpanded:
        {
            [self invokeDelegateSelector:@selector(bannerAdViewWillCollapse:)];
            
            if (self.expandedAdView != nil)
            {
                [self.expandedAdView mraidBridgeClose:self.expandedAdView.mraidBridge];
                self.expandedAdView = nil;
            }
            
            // Put the webview back on the base ad view (self).
            if (self.resizeView.superview) {
                [self.resizeView removeFromSuperview];
            }
            [self.webView setFrame:self.bounds];
            [self addSubview:self.webView];
            
            [self.webView scrollToTop];
                        
            [self dismissModalView:self.expandView animated:YES];
            
            [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateDefault];
            [self.mraidBridge setState:PMMRAIDBridgeStateDefault forWebView:self.webView];

            [self invokeDelegateSelector:@selector(bannerAdViewDidCollapse:)];
            
            [self resumeUpdates];

            break;
        }

        case PMMRAIDBridgeStateResized:
        {
            [self invokeDelegateSelector:@selector(bannerAdViewWillCollapse:)];
            
            [self.webView setFrame:self.bounds];
            [self addSubview:self.webView];
            
            [self.resizeView removeFromSuperview];
            
            [self.webView scrollToTop];
            
            [self prepareCloseButton];
            
            [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateDefault];
            [self.mraidBridge setState:PMMRAIDBridgeStateDefault forWebView:self.webView];
            
            [self invokeDelegateSelector:@selector(bannerAdViewDidCollapse:)];
            
            [self resumeUpdates];
            break;
        }
    }
}

- (void)mraidBridge:(PMMRAIDBridge *)bridge openURL:(NSString*)url
{
    [self openURLString:url];
}

- (void)mraidBridgeUpdateCurrentPosition:(PMMRAIDBridge*)bridge
{
    [self mraidUpdateLayoutForNewState:bridge.state];
}

- (void)mraidBridgeUpdatedExpandProperties:(PMMRAIDBridge*)bridge
{

}

- (void)mraidBridge:(PMMRAIDBridge*)bridge expandWithURL:(NSString*)url
{
    BOOL hasURL = [url length] != 0;
    
    if (self.placementType == PMAdViewPlacementInterstitial)
    {
        [bridge sendErrorMessage:@"Can not expand with placementType interstitial."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    switch (bridge.state)
    {
        case PMMRAIDBridgeStateLoading:
            // If loading and not an expanded URL, do nothing.
            if (self.isExpandedURL == NO)
                return;
            break;

        case PMMRAIDBridgeStateHidden:
            // Expand from these existing states is a no-op.
            return;
            
        case PMMRAIDBridgeStateExpanded:
            // Can not expand from the expanded state.
            return;
            
        default:
            // From default or resized the ad can expand.
            break;
    }
    
    // If there's a URL then use the expandedAdView (a different container) to 
    // render the ad and just update the state of the current ad to expanded.
    if (hasURL)
    {
        self.expandedAdView = [PMBannerAdView new];
        self.expandedAdView.adDescriptor = self.adDescriptor;
        self.expandedAdView.impTrackersExecuted = self.impTrackersExecuted;
        self.expandedAdView.delegate = self.delegate;
        [self.expandedAdView showExpanded:url withExpandProperties:self.mraidBridge.expandProperties];
        
        [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateExpanded];
        
        return;
    }
    
    [self invokeDelegateSelector:@selector(bannerAdViewWillExpand:)];
    
    // Reset the exanded view's frame.
    self.expandView.frame = self.modalViewController.view.bounds;

    // Move the webView to the expandView and update it's frame to match.
    [self.expandView addSubview:self.webView];
    [self.webView setFrame:self.expandView.bounds];
    
    [self.webView scrollToTop];
    
    [self presentModalView:self.expandView];
    
    [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateExpanded];
    [bridge setState:PMMRAIDBridgeStateExpanded forWebView:self.webView];
    
    [self prepareCloseButton];
    [self invokeDelegateSelector:@selector(bannerAdViewDidExpand:)];
}

- (void)mraidBridgeUpdatedOrientationProperties:(PMMRAIDBridge *)bridge
{
    self.modalViewController.allowRotation = bridge.orientationProperties.allowOrientationChange;
    
    if ((bridge.state == PMMRAIDBridgeStateExpanded) ||
        ((self.placementType == PMAdViewPlacementInterstitial) && (bridge.state == PMMRAIDBridgeStateDefault)))
    {
        switch (bridge.orientationProperties.forceOrientation)
        {
            case PMMRAIDOrientationPropertiesForceOrientationPortrait:
                [self.modalViewController forceRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                break;
                
            case PMMRAIDOrientationPropertiesForceOrientationLandscape:
                [self.modalViewController forceRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                break;
                
            case PMMRAIDOrientationPropertiesForceOrientationNone:
                break;
        }
    }
}

- (void)mraidBridgeUpdatedResizeProperties:(PMMRAIDBridge *)bridge
{
    
}

- (void)mraidBridgeResize:(PMMRAIDBridge*)bridge
{
    UIView* resizeViewSuperview = [self resizeViewSuperview];
    
    if (resizeViewSuperview == nil)
    {
        [bridge sendErrorMessage:@"Unable to determine superview for resize container view."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    if (self.placementType == PMAdViewPlacementInterstitial)
    {
        [bridge sendErrorMessage:@"Can not resize with placementType interstitial."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    switch (bridge.state)
    {
        case PMMRAIDBridgeStateLoading:
        case PMMRAIDBridgeStateHidden:
            // Resize from these existing states is a no-op.
            [bridge sendErrorMessage:@"Can not resize while loading or hidden."
                           forAction:@"resize"
                          forWebView:self.webView];
            return;
            
        case PMMRAIDBridgeStateExpanded:
            // Throw an error, don't change state.
            [bridge sendErrorMessage:@"Can not resize while expanded."
                           forAction:@"resize"
                          forWebView:self.webView];
            return;
            
        case PMMRAIDBridgeStateDefault:
        case PMMRAIDBridgeStateResized:
            // Both of these states cause a resize though
            // a resize event doesn't 'stack' so close only
            // unwinds 'one' resize back to default.
            break;
    }
    
    CGSize requestedSize = CGSizeMake(bridge.resizeProperties.width, bridge.resizeProperties.height);
    CGPoint requestedOffset = CGPointMake(bridge.resizeProperties.offsetX, bridge.resizeProperties.offsetY);
    
    // If a size isn't available just fail.
    if (CGSizeEqualToSize(requestedSize, CGSizeZero))
    {
        [bridge sendErrorMessage:@"Size required in resizeProperties."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }
    
    CGRect maxFrame = [self resizeViewMaxRect];
    
    // The actual max size for a resize must be less than the max size reported to the bridge.
    if ((requestedSize.width >= maxFrame.size.width) && (requestedSize.height >= maxFrame.size.height))
    {
        [bridge sendErrorMessage:@"Size must be smaller than the max size."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }

    CGRect currentFrame = [resizeViewSuperview convertRect:self.bounds fromView:self];
    CGRect convertRect = currentFrame;
    
    convertRect.origin.x += requestedOffset.x;
    convertRect.origin.y += requestedOffset.y;

    convertRect.size.height = requestedSize.height;
    convertRect.size.width = requestedSize.width;
    
    if (bridge.resizeProperties.allowOffscreen == NO)
    {
        if (CGRectContainsRect(maxFrame, convertRect) == NO)
        {
            // Adjust height and width to fit.
            if (CGRectGetWidth(convertRect) > CGRectGetWidth(maxFrame))
            {
                convertRect.size.width = CGRectGetWidth(maxFrame);
            }
            if (CGRectGetHeight(convertRect) > CGRectGetHeight(maxFrame))
            {
                convertRect.size.height = CGRectGetHeight(maxFrame);
            }
            
            // Adjust X
            if (CGRectGetMinX(convertRect) < CGRectGetMinX(maxFrame))
            {
                convertRect.origin.x = CGRectGetMinX(maxFrame);
            }
            else if (CGRectGetMaxX(convertRect) > CGRectGetMaxX(maxFrame))
            {
                CGFloat diff = CGRectGetMaxX(convertRect) - CGRectGetMaxX(maxFrame);
                convertRect.origin.x -= diff;
            }
            
            // Adjust Y
            if (CGRectGetMinY(convertRect) < CGRectGetMinY(maxFrame))
            {
                convertRect.origin.y = CGRectGetMinY(maxFrame);
            }
            else if (CGRectGetMaxY(convertRect) > CGRectGetMaxY(maxFrame))
            {
                CGFloat diff = CGRectGetMaxY(convertRect) - CGRectGetMaxY(maxFrame);
                convertRect.origin.y -= diff;
            }
        }
    }
    
    const CGFloat closeControlSize = 50;
    
    // Setup the "guaranteed" close area (invisible).
    // Note, this logic only uses the width and height from  convertRect and 0,0
    // as the top left since convertRect represents the resize view frame, not bounds.
    CGRect closeControlFrame = CGRectMake(convertRect.size.width - closeControlSize, 0,
                                          closeControlSize, closeControlSize);
    
    // Unlike expand the ad can specify the general location of the control area
    switch (bridge.resizeProperties.customClosePosition)
    {
        case PMMRAIDResizeCustomClosePositionTopRight:
            // Already configured above.
            break;
            
        case PMMRAIDResizeCustomClosePositionTopCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2, 0,
                                           closeControlSize, closeControlSize);
            break;
            
        case PMMRAIDResizeCustomClosePositionTopLeft:
            closeControlFrame = CGRectMake(0, 0,
                                           closeControlSize, closeControlSize);
            break;
            
        case PMMRAIDResizeCustomClosePositionBottomLeft:
            closeControlFrame = CGRectMake(0, convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case PMMRAIDResizeCustomClosePositionBottomRight:
            closeControlFrame = CGRectMake(convertRect.size.width - closeControlSize,
                                           convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case PMMRAIDResizeCustomClosePositionBottomCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2,
                                           convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case PMMRAIDResizeCustomClosePositionCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2,
                                           convertRect.size.height/2 - closeControlSize/2,
                                           closeControlSize, closeControlSize);
            break;
    }
    
    // Create a frame relative to the maxFrame from the closeControl frame.
    CGRect maxCloseControlFrame = closeControlFrame;
    maxCloseControlFrame.origin.x += convertRect.origin.x;
    maxCloseControlFrame.origin.y += convertRect.origin.y;
    
    // Determine if any of the close control will end up off screen.
    if (CGRectContainsRect(maxFrame, maxCloseControlFrame) == NO)
    {
        [bridge sendErrorMessage:@"Resize close control must remain on screen."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(bannerAdView:willResizeToFrame:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate bannerAdView:self willResizeToFrame:convertRect];
        }];
    }

    self.resizeView.frame = convertRect;
    [self.resizeView addSubview:self.webView];
    [self.webView setFrame:self.resizeView.bounds];
    [resizeViewSuperview addSubview:self.resizeView];
    
    [self showCloseButtonAtPosition:closeControlFrame.origin onView:self.resizeView];

    // Update the bridge.
    [self mraidUpdateLayoutForNewState:PMMRAIDBridgeStateResized];
    [bridge setState:PMMRAIDBridgeStateResized forWebView:self.webView];
    
    if ([self.delegate respondsToSelector:@selector(bannerAdView:didResizeToFrame:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate bannerAdView:self didResizeToFrame:convertRect];
        }];
    }
}

- (void)mraidBridge:(PMMRAIDBridge*)bridge playVideo:(NSString*)url
{
    // Default to launching the player and allow a developer to override.
    __block BOOL play = YES;
    [self performClickTracking];
    if ([self.delegate respondsToSelector:@selector(bannerAdView:shouldPlayVideo:)])
    {
        [self invokeDelegateBlock:^
        {
            play = [self.delegate bannerAdView:self shouldPlayVideo:url];
        }];
    }
    
    if (play)
    {
        [self invokeDelegateSelector:@selector(bannerAdViewWillLeaveApplication:)];
        
        self.skipNextUpdateTick = YES;
        [PMSDKUtil openURL:[NSURL URLWithString:url]];
    }
}

- (void)mraidBridge:(PMMRAIDBridge*)bridge createCalenderEvent:(NSString*)event
{
    __weak typeof(self) weakSelf = self;
    [self canAccessCalendar:^(BOOL granted) {
        if (granted) {
            [weakSelf performSelectorInBackground:@selector(createCalendarEvent:) withObject:event];
        }else{
            [weakSelf.mraidBridge sendErrorMessage:@"Access denied."
                                     forAction:@"createCalendarEvent"
                                    forWebView:weakSelf.webView];
        }
    }];
}

- (void)mraidBridge:(PMMRAIDBridge*)bridge storePicture:(NSString*)url
{
    [self performSelectorInBackground:@selector(loadAndSavePhoto:) withObject:url];
}

#pragma mark - View

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.adDescriptor == nil)
        return;
    
    if (self.placementType == PMAdViewPlacementInterstitial)
        return;
    
    [self performAdTracking];
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
}

// Updates MRAID on size changes.
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
}

- (void)removeFromSuperview
{
    // To avoid NSTimer retaining instances of the PMBannerAdView all timers MUST be cancled when the view
    // is no longer attached to a superview.
    
    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
        WarnLog(@"CAUTION: removeFromSuperview invoked with live timers.  Be sure to call [PMBannerAdView reset] if the superview is being deallocated/destoryed and no longer referenced.");
    }
    
    // Stop the interstitial timer
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;

        WarnLog(@"CAUTION: removeFromSuperview invoked with live timers.  Be sure to call [PMBannerAdView reset] if the superview is being deallocated/destoryed and no longer referenced.");
    }
    
    [super removeFromSuperview];
}

#pragma mark - Calendar Interactions
-(void)canAccessCalendar:(void(^)(BOOL granted))callback{
    
    __block BOOL calendarAuthorized = NO;
    if ([self.delegate respondsToSelector:@selector(bannerAdViewSupportsCalendar:)]) {
        calendarAuthorized = [self.delegate bannerAdViewSupportsCalendar:self];
    }
    
    if (calendarAuthorized){
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
            NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:CALENDAR_USAGE_DESC_KEY];
            
            if (accessDescription == nil) {
                WarnLog(@"Missing usage description for '%@' key in your plist file. This is required to enable ads to use device calendar.",CALENDAR_USAGE_DESC_KEY);
                callback(NO);
                return;
            }
        }
        
        @autoreleasepool
        {
            EKEventStore* store = [EKEventStore new];
            
            [store requestAccessToEntityType:EKEntityTypeEvent
                                  completion:^(BOOL granted, NSError *error)
             {
                 if (error) {
                     ErrorLog([error localizedDescription]);  
                 }
                 callback(granted);
             }];
        }
    }else{
        callback(NO);
    }
}

// Background thread (Event Kit can be slow to load)
- (void)createCalendarEvent:(NSString*)jEvent
{
    runOnMainQueueIfNot(^{
        [self performClickTracking];
    });
    @autoreleasepool
    {
        if ([self.delegate respondsToSelector:@selector(bannerAdView:shouldSaveCalendarEvent:inEventStore:)] == NO)
        {
            [self.mraidBridge sendErrorMessage:@"Access denied."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            return;
        }
        
        NSError * error = nil;
        NSDictionary* jDict = [NSJSONSerialization JSONObjectWithData:[jEvent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        if (error)
        {
            [self.mraidBridge sendErrorMessage:@"Unable to parse event data."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            return;
        }
        
        EKEventStore* store = [[EKEventStore alloc] init];
        EKEvent* event = [EKEvent eventWithEventStore:store];
        
        NSDate* start = [PMSDKUtil dateFromW3CCalendarDate:[jDict valueForKey:@"start"]];
        if (start == nil){
            start = [NSDate date];
        }
        
        NSDate* end = [PMSDKUtil dateFromW3CCalendarDate:[jDict valueForKey:@"end"]];
        if (end == nil){
            end = [start dateByAddingTimeInterval:3600];
        }
        
        event.title = [jDict valueForKey:@"summary"];
        event.notes = [jDict valueForKey:@"description"];
        event.location = [jDict valueForKey:@"location"];
        event.startDate = start;
        event.endDate = end;
        
        id reminder = [jDict valueForKey:@"reminder"];
        if (reminder != nil)
        {
            EKAlarm* alarm = nil;
            
            if ([reminder isKindOfClass:[NSString class]])
            {
                NSDate* reminderDate = [PMSDKUtil dateFromW3CCalendarDate:reminder];
                if (reminderDate != nil)
                {
                    alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
                }
                else
                {
                    alarm = [EKAlarm alarmWithRelativeOffset:[reminder doubleValue] / 1000.0];
                }
            }
            
            if (alarm != nil)
            {
                [event addAlarm:alarm];
            }
        }
        
        [self invokeDelegateBlock:^
         {
             BOOL shouldSave = [self.delegate bannerAdView:self
                                 shouldSaveCalendarEvent:event
                                            inEventStore:store];
             
             UIViewController* rootViewController = [self modalRootViewController];

             // Included in this block since this block occurs on the main thread and the
             // following must be on the main thread since it's interacting with the UI.
             if (shouldSave && (rootViewController != nil))
             {
                 EKEventEditViewController* eventViewController = [EKEventEditViewController new];
                 eventViewController.eventStore = store;
                 eventViewController.event = event;
                 eventViewController.editViewDelegate = self;
                 
                 [rootViewController presentViewController:eventViewController animated:YES completion:^{
                     
                 }];

             }
             else
             {
                 // User didn't supply a controler to present the event edit controller on.
                 [self.mraidBridge sendErrorMessage:@"Access denied."
                                          forAction:@"createCalendarEvent"
                                         forWebView:self.webView];
             }
         }];
    }
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action)
    {
        case EKEventEditViewActionCanceled:
        case EKEventEditViewActionDeleted:
        {
            [self.mraidBridge sendErrorMessage:@"User canceled."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            break;
        }
            
        case EKEventEditViewActionSaved:
        {
            NSError* error = nil;
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            
            if (error != nil)
            {
                NSString* errorMessage = [error description];
                [self.mraidBridge sendErrorMessage:errorMessage
                                         forAction:@"createCalendarEvent"
                                        forWebView:self.webView];
                
                ErrorLog(@"Unable to save calendar event for ad: %@",errorMessage);
            }
            break;
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Photo Saving

// Background thread
- (void)loadAndSavePhoto:(NSString*)imageURL
{
    runOnMainQueueIfNot(^{
        [self performClickTracking];
    });
    @autoreleasepool
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
            NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:PHOTO_LIB_USAGE_DESC_KEY];
            
            if (accessDescription == nil) {
                WarnLog(@"Missing usage description for '%@' key in your plist file. This is required to enable ads to use device photo library.",PHOTO_LIB_USAGE_DESC_KEY);
                return;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(bannerAdView:shouldSavePhotoToCameraRoll:)] == NO)
        {
            return;
        }
        
        NSError* error = nil;
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]
                                                  options:NSDataReadingUncached
                                                    error:&error];
        if (error != nil)
        {
            [self.mraidBridge sendErrorMessage:error.description
                                     forAction:@"storePicture"
                                    forWebView:self.webView];
            
            ErrorLog(@"Error obtaining photo requested to save to camera roll: %@", error.description);
            return;
        }
        
        UIImage* image = [UIImage imageWithData:imageData];
        
        __block BOOL save = NO;
        
        [self invokeDelegateBlock:^
         {
             save = [self.delegate bannerAdView:self shouldSavePhotoToCameraRoll:image];
         }];
        
        if (save)
        {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }
}

#pragma mark - Ad Loading

- (PMAdDescriptor*)descriptorForBid:(NSDictionary*)bidDetails
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[bidDetails valueForKey:@"impid"] forKey:@"id"];
    [dict setValue:[[bidDetails valueForKey:@"price"] stringValue] forKey:@"ecpm"];
    [dict setValue:[bidDetails valueForKey:@"adm"] forKey:@"creative_tag"];
    [dict setValue:[[bidDetails valueForKey:@"w"] stringValue] forKey:@"width"];
    [dict setValue:[[bidDetails valueForKey:@"h"] stringValue] forKey:@"height"];
    
    if ([bidDetails valueForKey:@"ext"] && [[bidDetails valueForKey:@"ext"] valueForKey:@"extension"])
    {
        NSDictionary *extension = [[bidDetails valueForKey:@"ext"] valueForKey:@"extension"];
        [dict setValue:[extension valueForKey:@"trackingUrl"] forKey:@"tracking_url"];
        [dict setValue:[extension valueForKey:@"clicktrackingurl"] forKey:@"click_tracking_url"];
    }
    
    PMAdDescriptor *descriptor = [[PMAdDescriptor alloc] initWithJSONAttributes:dict];
    return descriptor;
}

- (void)renderWithPrefetcher:(id<PMResponseGenerator>)prefetcher forImpressionId:(NSString*)impressionId andRequest:(PMBaseAdRequest *)adRequest{
    
    self.adRequest = adRequest;
    NSDictionary *bidDict = [prefetcher prefetchedResponseForImpressionId:impressionId];
    if (!bidDict) {
        DebugLog(@"Unable to render ad for this impression");
        return;
    }
    PMAdDescriptor* bannerAdDescriptor = [self descriptorForBid:bidDict];
    [self renderWithAdDescriptor:bannerAdDescriptor];
}

// Background (or main thread if called manually).
- (void)renderWithAdDescriptor:(PMAdDescriptor*)ad{
    
    self.adDescriptor = ad;
    
    __weak typeof(self) weakSelf = self;
    if ([ad.content length]){
        
        runOnMainQueueIfNot(^{
            
            weakSelf.impTrackersExecuted = NO;
            weakSelf.clickTrackersExecuted = NO;
            [weakSelf renderMRAIDAd:ad.content andFireTrackers:(self.placementType != PMAdViewPlacementInterstitial)];
        });

    }else{
        
        NSString* errorMessage = [NSString stringWithFormat:@"Ad descriptor missing ad content"];
        ErrorLog(errorMessage);
        
        if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 [weakSelf.delegate bannerAdView:weakSelf didFailToReceiveAdWithError:[PMError errorWithCode:kPMErrorInvalidResponse description:errorMessage]];
             }];
        }
    }
}

#pragma mark - Tracking

-(void) sendImpression
{
    [self performAdTracking];
}

-(void) sendClickTracker
{
    [self performClickTracking];
}

- (void)performAdTracking
{
    
    if (self.impTrackersExecuted) {
        return;
    }
    self.impTrackersExecuted = YES;
    
    NSString *impressionTracker = self.adDescriptor.impressiontracker;
    
    if ([impressionTracker length] > 0){
        
        [self.serverCommunicator trackURL:impressionTracker success:^(NSData *data, NSURLResponse *response) {
            InfoLog(@"Sucessfully executed Impression Tracker URL %@",response.URL.absoluteString);
        } failure:^(PMError *error) {
            ErrorLog(@"Error code: %ld Failed to execute impression tracker with URL: %@", error.code, impressionTracker);
        }];
    }
}

-(void) performClickTracking{
    
    if (self.clickTrackersExecuted) {
        return;
    }
    self.clickTrackersExecuted = YES;
    
    NSString *tracker= self.adDescriptor.clickTracker;
    if ([tracker length] > 0){
        
        [self.serverCommunicator trackURL:tracker success:^(NSData *data, NSURLResponse *response) {
            
            InfoLog(@"Sucessfully executed Click Tracker URL %@",response.URL.absoluteString);
            
        } failure:^(PMError *error) {
            
            ErrorLog(@"Error code: %ld Failed to execute click tracker with URL: %@", error.code, tracker);

        }];
    }
}

#pragma mark - Delegate Callbacks

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
// will block until the main thre   ad executes the block.
- (void)invokeDelegateBlock:(dispatch_block_t)block
{
    runOnMainQueueIfNot(block);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* scheme = [[request URL] scheme];
    
    if ([scheme isEqualToString:@"console"])
    {
#ifdef DEBUG
        NSString* l = [[request URL] query];
        NSString* logString = (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)l, CFSTR(""));
        DebugLog(@"UIWebView console: %@", logString);
#endif
        return NO;
    }
    
    if ([scheme isEqualToString:@"mraid"])
    {
        BOOL handled = [self.mraidBridge parseRequest:request];
        
        if (handled)
        {
            return NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(bannerAdView:didProcessRichmediaRequest:)])
        {
            [self invokeDelegateBlock:^
            {
                [self.delegate bannerAdView:self didProcessRichmediaRequest:request];
            }];
        }
    }
    
    if ([@"about" isEqualToString:scheme])
    {
        return YES;
    }
    
    // Normally canOpenInternall would be processed inside the navigation type selection.
    // However, it's being done outside becuase of the above handling of UIWebViewNavigationTypeOther.
    BOOL canOpenInternal = [PMSDKUtil canInternalBrowserOpenURL:request.URL];

    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [self openURLString:request.URL.absoluteString];
        
        // Never let the ad's window render the destination link.
        return NO;
    }

    if ((navigationType == UIWebViewNavigationTypeOther) && (canOpenInternal == NO))
    {
        [self openURLString:request.URL.absoluteString];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wv{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    @autoreleasepool
    {
        [wv disableSelection];
        [self mraidInitializeBridge:self.mraidBridge forWebView:wv];
    }
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    ErrorLog([error description]);
    
    if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailToReceiveAdWithError:)])
    {
        [self invokeDelegateBlock:^
         {
             [self.delegate bannerAdView:self didFailToReceiveAdWithError:[PMError errorWithCode:kPMErrorRenderError description:error.localizedDescription]];
         }];
    }
}

#pragma mark - Location Services

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

#pragma mark - UI helpers

- (CGSize)screenSizeIncludingStatusBar:(BOOL)includeStatusBar
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (includeStatusBar) {
        return screenSize;
    }else{

        if ([[UIApplication sharedApplication] isStatusBarHidden]) {
            return screenSize;
        }else{
            
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            screenSize.height -= CGRectGetHeight(statusBarFrame);
            return screenSize;
        }
    }
}

- (CGRect)absoluteFrameForView:(UIView*)view
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect windowRect = [[[UIApplication sharedApplication] keyWindow] bounds];
    CGRect rectAbsolute = [view convertRect:view.bounds toView:nil];
    rectAbsolute = PMFixOriginRotation(rectAbsolute, interfaceOrientation,
                                         windowRect.size.width, windowRect.size.height);
    return rectAbsolute;
}

// Attribution: http://stackoverflow.com/questions/6034584/iphone-correct-landscape-window-coordinates
CGRect PMFixOriginRotation(CGRect rect, UIInterfaceOrientation orientation, int parentWidth, int parentHeight) 
{
    CGRect newRect = CGRectZero;
    switch(orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), rect.origin.y, rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            newRect = CGRectMake(rect.origin.x, parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationPortrait:
            newRect = rect;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
            
        default:
            // Implemented to supress warnings
            break;
    }
    return newRect;
}

#pragma methods to set image size returned in response of type image

-(CGSize)getAdSize
{
    return self.adDescriptor.adSize;
}
@end
