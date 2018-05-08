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

#import "PMInterstitialAd.h"
#import "PMAdDescriptor.h"
#import "PMBaseAdRequest.h"
#import "PMLogger.h"
#import "FoundationCategories.h"
#import "PMError.h"

@interface PMBannerAdView()
-(void)closeInterstitial;
-(void)showInterstitial;
-(void)renderWithAdDescriptor:(PMAdDescriptor*)ad;
-(void)showInterstitialForDuration:(NSTimeInterval)duration;
-(id)initInterstitial;
-(void)showCloseButtonAfterDelay:(NSTimeInterval)delay;
@end

@interface PMInterstitialAd()<PMBannerAdViewDelegate>
@property (nonatomic, weak) id<PMInterstitialAdDelegate> interstitialAdDelegate;
@property (nonatomic , strong) PMBannerAdView * interstitialAd;
@property (nonatomic ) BOOL isInterstitialShown;
@end

@implementation PMInterstitialAd
-(void)dealloc{

    self.interstitialAd = nil;
}

-(void)loadRequest:(PMBaseAdRequest *)adRequest{
    
    _isReady = NO;
    _isInterstitialShown = NO;
    [self.interstitialAd loadRequest:adRequest];
}

-(instancetype)init{
    
    self = [super init];
    if (self) {
        self.interstitialAd = [[PMBannerAdView alloc] initInterstitial];
        self.interstitialAd.delegate = self;
    }
    return self;
}

-(PMAdResponse *)adResponse{
 
    return [self.interstitialAd valueForKey:@"adResponse"];
}

-(void)close{
    
    return [self.interstitialAd closeInterstitial];
}

-(void)show{
    
    [self showForDuration:0];
}

-(void)showForDuration:(NSTimeInterval)duration{
    
    PMError * error = nil;
    
    if (_isReady) {
        if (!_isInterstitialShown) {
            _isInterstitialShown = YES;
            [self.interstitialAd showInterstitialForDuration:duration];
        }else{
            error = [PMError errorWithCode:kPMErrorInterstitialAlreadyUsed description:@"Ad is already shown, please request new ad"];
        }
    }else{
        WarnLog(@"Can't present interstitial. It is not ready.");
    }
    
    if (error) {

        ErrorLog(@"Error code: %ld, Description: %@",error.code, error.localizedDescription);

        if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:didFailToReceiveAdWithError:)]) {
            
            [self.interstitialAdDelegate interstitialAd:self didFailToReceiveAdWithError:error];
            
        }
    }
}

- (void)renderWithPrefetcher:(id<PMResponseGenerator>)prefetcher forImpressionId:(NSString *)impressionId andRequest:(PMBaseAdRequest *)adRequest
{
    [self.interstitialAd renderWithPrefetcher:prefetcher forImpressionId:impressionId andRequest:adRequest];
}

-(void)showCloseButtonAfterDelay:(NSTimeInterval)delay{
 
    [self.interstitialAd showCloseButtonAfterDelay:delay];
}

-(void)setUseInternalBrowser:(BOOL)useInternalBrowser{
    
    [self.interstitialAd setUseInternalBrowser:useInternalBrowser];
}

-(void)setDelegate:(id<PMInterstitialAdDelegate>)delegate{
    
    self.interstitialAdDelegate = delegate;
}

#pragma PMBannerAdView delegate methods
- (void)bannerAdViewDidRecieveAd:(PMBannerAdView *)adView{
    
    _isReady = YES;

    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdDidRecieveAd:)]) {
        
        [self.interstitialAdDelegate interstitialAdDidRecieveAd:self];
    }

}

- (void)bannerAdView:(PMBannerAdView*)adView didFailToReceiveAdWithError:(PMError*)error{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:didFailToReceiveAdWithError:)]) {
        
        [self.interstitialAdDelegate interstitialAd:self didFailToReceiveAdWithError:error];

    }
}

- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldOpenURL:(NSURL*)url{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:shouldOpenURL:)]) {
        return [self.interstitialAdDelegate interstitialAd:self shouldOpenURL:url];
    }
    return YES;
}

- (void)bannerAdViewCloseButtonPressed:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdCloseButtonPressed:)]) {
        [self.interstitialAdDelegate interstitialAdCloseButtonPressed:self];
    }
    [self.interstitialAd closeInterstitial];
}

- (UIButton*)bannerAdViewCustomCloseButton:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdCustomCloseButton:)]) {
        return [self.interstitialAdDelegate interstitialAdCustomCloseButton:self];
    }
    return nil;
}

- (void)bannerAdViewInternalBrowserWillOpen:(PMBannerAdView*)adView{

    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdInternalBrowserWillOpen:)]) {
        [self.interstitialAdDelegate interstitialAdInternalBrowserWillOpen:self];
    }
}

- (void)bannerAdViewInternalBrowserDidOpen:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdInternalBrowserDidOpen:)]) {
        [self.interstitialAdDelegate interstitialAdInternalBrowserDidOpen:self];
    }
}

- (void)bannerAdViewInternalBrowserWillClose:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdInternalBrowserWillClose:)]) {
        [self.interstitialAdDelegate interstitialAdInternalBrowserWillClose:self];
    }
}

- (void)bannerAdViewInternalBrowserDidClose:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdInternalBrowserDidClose:)]) {
        [self.interstitialAdDelegate interstitialAdInternalBrowserDidClose:self];
    }
}

- (void)bannerAdViewWillLeaveApplication:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdWillLeaveApplication:)]) {
        [self.interstitialAdDelegate interstitialAdWillLeaveApplication:self];
    }
}

- (BOOL)bannerAdViewSupportsSMS:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdSupportsSMS:)]) {
        return [self.interstitialAdDelegate interstitialAdSupportsSMS:self];
    }
    //Device capabilities will override return value
    return YES;
}

- (BOOL)bannerAdViewSupportsPhone:(PMBannerAdView*)adView{
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdSupportsPhone:)]) {
        return [self.interstitialAdDelegate interstitialAdSupportsPhone:self];
    }
    //Device capabilities will override returned value
    return YES;
}

- (BOOL)bannerAdViewSupportsCalendar:(PMBannerAdView*)adView{
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdSupportsCalendar:)]) {
        return [self.interstitialAdDelegate interstitialAdSupportsCalendar:self];
    }
    return NO;
}

- (BOOL)bannerAdViewSupportsStorePicture:(PMBannerAdView*)adView{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdSupportsStorePicture:)]) {
        return [self.interstitialAdDelegate interstitialAdSupportsStorePicture:self];
    }
    return NO;
}

- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldPlayVideo:(NSString*)videoURL{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:shouldPlayVideo:)]) {
        return [self.interstitialAdDelegate interstitialAd:self shouldPlayVideo:videoURL];
    }
    return YES;
}

- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldSaveCalendarEvent:(EKEvent*)event inEventStore:(EKEventStore*)eventStore{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:shouldSaveCalendarEvent:inEventStore:)]) {
        return [self.interstitialAdDelegate interstitialAd:self shouldSaveCalendarEvent:event inEventStore:eventStore];
    }
    return NO;

}

- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldSavePhotoToCameraRoll:(UIImage*)image{
    
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:shouldSavePhotoToCameraRoll:)]) {
        return [self.interstitialAdDelegate interstitialAd:self shouldSavePhotoToCameraRoll:image];
    }
    return NO;
}

- (void)bannerAdView:(PMBannerAdView *)adView didProcessRichmediaRequest:(NSURLRequest*)event{
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAd:didProcessRichmediaRequest:)]) {
        [self.interstitialAdDelegate interstitialAd:self didProcessRichmediaRequest:event];
    }
}

- (UIViewController*)bannerAdViewPresentationController:(PMBannerAdView*)adView
{
    if ([self.interstitialAdDelegate respondsToSelector:@selector(interstitialAdPresentationController:)]) {
        return [self.interstitialAdDelegate interstitialAdPresentationController:self];
    }
    return nil;
}

@end
