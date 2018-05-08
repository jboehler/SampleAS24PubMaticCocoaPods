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


#import "PMBannerAdView.h"
#import "PMInterstitialAdDelegate.h"
#import "PMInterstitialAdRequest.h"

/*! Request and renders Interstitial Ads.
 */

@interface PMInterstitialAd : NSObject<PMAdRenderer>

/*! Sets the PMInterstitialAdDelegate delegate receiever for the ad view.
 
 @warning Proper reference management practices should be observed when using delegates.
 @warning Ensure that the delegate is set to nil prior to releasing the ad view's instance.
 */
@property (nonatomic, weak) id<PMInterstitialAdDelegate> delegate;

/*
 @abstract Starts loading given Ad request
 @discussion Ad request must be of type PMInterstitialAdRequest
 @param Ad request instance of PMInterstitialAdRequest
 */
-(void)loadRequest:(PMBaseAdRequest *)adRequest;

/*!
 Returns YES if the interstitial is ready to be displayed. The delegate’s interstitialAdDidRecieveAd: will be called after this property switches from NO to YES.
 */
@property (nonatomic, assign, readonly) BOOL isReady;

/*! Presents interstitial Ad in full screen view until the user dismisses it. This has no effect unless isReady returns YES and/or the delegate’s interstitialAdDidRecieveAd: has been received.
  */
- (void)show;

/*! Presents the interstitial and automatically closes after the specified duration.
 
 @param duration The amount of time to display the interstitial before closing it.
 */
- (void)showForDuration:(NSTimeInterval)duration;

/*! 
 Shows a close button after the specified delay after the ad is rendered.
 
 This is applicable for custom close buttons as well, The close button can be customized using the
 interstitialAdCustomCloseButton: delegate method.
 
 @param delay The time to delay showing the close button after rendering the ad.  A
 value of 0 will show the button immediately.
 */
 - (void)showCloseButtonAfterDelay:(NSTimeInterval)delay;

/*! Closes the interstitial.
 */
- (void)close;

/*! Set to enable the use of the internal browser for opening ad content.  Defaults to `NO`.
 
 @see isInternalBrowserOpen
 @see [PMInterstitialAdDelegate interstitialAdViewInternalBrowserWillOpen:]
 @see [PMInterstitialAdDelegate interstitialAdViewInternalBrowserDidOpen:]
 @see [PMInterstitialAdDelegate interstitialAdViewInternalBrowserWillClose:]
 @see [PMInterstitialAdDelegate interstitialAdViewInternalBrowserDidClose:]
 */
@property (nonatomic, assign) BOOL useInternalBrowser;


@end


