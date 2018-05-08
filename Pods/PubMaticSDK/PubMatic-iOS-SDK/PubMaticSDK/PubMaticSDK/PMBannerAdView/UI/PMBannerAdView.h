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

/*
  
    PMBannerAdView
 */

#import <EventKitUI/EventKitUI.h>
#import <MessageUI/MessageUI.h>

#import "PMBannerAdViewDelegate.h"
#import "PMBannerAdRequest.h"

@class PMBannerAdView;

/*! Renders simple Banner & Rich media Ads.
 */
@interface PMBannerAdView: UIView<PMAdRenderer>

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/*! Initilizes an inline instance of the ad view.
 
 The view can be added to other views as with any other UIView object.  The frame is
 used to determine the size of the ad in the requested to the ad server.  If not known
 at initialization time, ensure that the view's frame is set prior to calling [PMBannerAdView loadRequest:].
 
 @param frame The area to place the view.
 */
- (id)initWithFrame:(CGRect)frame;

/*! Sets the PMBannerAdViewDelegate delegate receiver for the ad view.
 
 @warning Proper reference management practices should be observed when using delegates.
 @warning Ensure that the delegate is set to nil prior to setting nil to Banner ad view's object reference.
 */
@property (nonatomic, weak) id<PMBannerAdViewDelegate> delegate;

/*!
 @abstract Starts loading given Ad request
 @discussion Ad request must be of type PMBannerAdRequest
 @param adRequest instance of PMBannerAdRequest
 */
-(void)loadRequest:(PMBaseAdRequest *)adRequest;

/*!
 @abstract Time in seconds after which ad will udpated/refreshed
 @discussion By default Banner Ad view do not autorefresh, to enable auto refresh set updateInterval to non zero value, Expected value should be in range of 12 to 120.
 Below Ad refresh behaviour for given updateInterval=X
 
 - X<=0    Ad will not refresh
 - X > 0 & X <= 12    Ad will refresh after every 12 seconds.
 - X > 12 & X <=120    Ad will refresh after every X seconds
 - X > 120    Ad will refresh after every 120 seconds
 
 @warning updateInterval should be set before calling [PMBannerAdView loadRequest:].
 */
@property (nonatomic) NSTimeInterval updateInterval;

/*! Set to enable the use of the internal browser for opening ad content.  Defaults to `NO`.
 
 @see isInternalBrowserOpen
 @see [PMBannerAdViewDelegate bannerAdViewInternalBrowserWillOpen:]
 @see [PMBannerAdViewDelegate bannerAdViewInternalBrowserDidOpen:]
 @see [PMBannerAdViewDelegate bannerAdViewInternalBrowserWillClose:]
 @see [PMBannerAdViewDelegate bannerAdViewInternalBrowserDidClose:]
 */
@property (nonatomic, assign) BOOL useInternalBrowser;

/*! Resets the instance to its default state.
 
 - Stops updates and cancels the update interval.
 - Stops location detection.
 - Collapses any expanded or resized richmedia ads.
 - Closes internal ad browser.
 
 Should be sent before releasing the instance if another object may be retaining it
 such as a superview or list.  This allows the application to suspend ad updating
 and interaction activities to allow other application activitis to occur.
 
 @warning If the project is using ARC (automatic reference counting) this MUST be called
 to cancel internal timers.  If not the main NSRunLoop will retain a reference to the
 PMBannerAdViewinstance and continue invoking its timers.
 @warning Does not reset the delegate.
 */
- (void)reset;

/*! Removes any displayed ad content and any associated state.
 
 - Collapses any expanded or resized richmedia ads.
 - Cancels any deferred update.
 
 Unlike reset, it does not reset the instance to it's default state.
 
 */
- (void)removeContent;

/*!
 Ad size received in ad response.
 @warning Ad size will be availabe only after successful Ad response. i.e. when bannerAdViewDidRecieveAd: delegate method is called
 */
- (CGSize)getAdSize;

/*! Returns the status of the internal browser.
 
 @see useInternalBrowser
 */
@property (nonatomic, readonly) BOOL isInternalBrowserOpen;
@end
