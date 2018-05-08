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

#ifndef PMBannerAdViewDelegate_h
#define PMBannerAdViewDelegate_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PMError.h"
@class  PMBannerAdView ;

/*! Protocol for interaction with the PMBannerAdView.
 
 The entire protocol is optional. Some methods override default behavior and some are required
 to get full support for MRAID 2 ad content (saving calendar entries or pictures).
 
 All messages are guaranteed to occur on the main thread.  If any long running tasks are needed
 in reponse to any of the sent messages then they should be executed in a background thread to
 prevent and UI delays for the user.
 */
@protocol PMBannerAdViewDelegate <NSObject>
@optional


///---------------------------------------------------------------------------------------
/// @name Ad Updates
///---------------------------------------------------------------------------------------

/*! Sent after an ad has been downloaded and rendered.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewDidRecieveAd:(PMBannerAdView *)adView;


/*! Sent if an error was encoutered while downloading or rendering an ad.
 
 @param adView The PMBannerAdView instance sending the message.
 @param error The error encountered while attempting to receive or render the ad.
 */
- (void)bannerAdView:(PMBannerAdView*)adView didFailToReceiveAdWithError:(PMError*)error;


/*! Sent when the ad will navigate to a clicked link.
 
 Not implementing this method behaves as if `YES` was returned.
 
 @param adView The PMBannerAdView instance sending the message.
 @param url The URL to open.
 @return `YES` Allow the SDK to open the link with UIApplication's openURL: or the internal browser.
 @return `NO` Ignore the request
 */
- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldOpenURL:(NSURL*)url;

/*! Sent before the ad opens a URL that invokes another application (ex: Safari or App Store).
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewWillLeaveApplication:(PMBannerAdView*)adView;


///---------------------------------------------------------------------------------------
/// @name Internal Browser Events
///---------------------------------------------------------------------------------------

/*! Sent before the internal browser is opened.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewInternalBrowserWillOpen:(PMBannerAdView*)adView;


/*! Sent after the internal browser is opened.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewInternalBrowserDidOpen:(PMBannerAdView*)adView;


/*! Sent before the internal browser is closed.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewInternalBrowserWillClose:(PMBannerAdView*)adView;


/*! Sent after the internal browser is closed.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewInternalBrowserDidClose:(PMBannerAdView*)adView;



///---------------------------------------------------------------------------------------
/// @name Rich Media Ad Events
///---------------------------------------------------------------------------------------

/*! Sent before the ad content is expanded in response to a richmedia expand event.
 
 The ad view itself is not expanded, instead a new window is displayed with the
 expanded ad content.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewWillExpand:(PMBannerAdView*)adView;


/*! Sent after the ad content is expanded in response to a richmedia expand event.
 
 The ad view itself is not expanded, instead a new window is displayed with the
 expanded ad content.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewDidExpand:(PMBannerAdView*)adView;


/*! Sent before the ad content is resized in response to a richmedia resize event.
 
 The ad view itself is not resized, instead a new window is displayed with the
 resized ad content.
 
 @param adView The PMBannerAdView instance sending the message.
 @param frame The frame relative to the window where the resized content is displayed.
 */
- (void)bannerAdView:(PMBannerAdView *)adView willResizeToFrame:(CGRect)frame;


/*! Sent after the ad content is resized in response to a richmedia resize event.
 
 The ad view itself is not resized, instead a new window is displayed with the
 resized ad content.
 
 @param adView The PMBannerAdView instance sending the message.
 @param frame The frame relative to the window where the resized content is displayed.
 */
- (void)bannerAdView:(PMBannerAdView *)adView didResizeToFrame:(CGRect)frame;


/*! Sent before ad content is collaped if expanded or resized.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewWillCollapse:(PMBannerAdView*)adView;


/*! Sent after ad content is collaped if expanded or resized.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewDidCollapse:(PMBannerAdView*)adView;

/*! Sent when the close button is pressed by the user.
 
 This only occurs for the close button enabled with setCloseButton:afterDelay: or in the case of a
 interstitial richmedia ad that closes itself.  It will not be sent for richmedia close buttons that
 collapse expanded or resized ads.
 
 The common use case is for interstitial ads so the developer will know when to call closeInterstitial.
 
 @param adView The PMBannerAdView instance sending the message.
 */
- (void)bannerAdViewCloseButtonPressed:(PMBannerAdView*)adView;


/*! Implement to return a custom close button.
 
 This button will be used for richmedia ads if the richmedia ad does not indicate it has its own
 custom close button.  It is also used if showCloseButton:afterDelay: enables the close button.
 
 @warning Do not return the same UIButton instance to different adView instances.
 
 @warning Developers should take care of adding action handlers to the button as it will
 be reused and may persist beyond the handlers lifetime.
 
 @param adView The PMBannerAdView instance sending the message.
 @return UIButton instance.
 */
- (UIButton*)bannerAdViewCustomCloseButton:(PMBannerAdView*)adView;

/*! Sent to allow developers to override SMS support.
 
 If the device supports SMS this message will be sent to allow the developer to override support.
 The default behavior is to allow SMS usage.
 
 This message is not sent of the device does not support SMS.
 
 @param adView The PMBannerAdView instance sending the message.
 @return `NO` Informs richmedia ads that SMS is not supported.
 @return `YES` Informs richmedia ads that SMS is supported.
 */
- (BOOL)bannerAdViewSupportsSMS:(PMBannerAdView*)adView;


/*! Sent to allow developers to override phone support.
 
 If the device supports phone dialling this message will be sent to allow the developer to override support.
 The default behavior is to allow phone dialing.
 
 This message is not sent of the device does not support phone dialing.
 
 @param adView The PMBannerAdView instance sending the message.
 @return `NO` Informs richmedia ads that phone calls is not supported.
 @return `YES` Informs richmedia ads that phone calls is supported.
 */
- (BOOL)bannerAdViewSupportsPhone:(PMBannerAdView*)adView;


/*! Sent to allow developers to override calendar support.
 
 Implement to indicate if calendar events can be created.
 The default behavior is to NOT allow calendar access.
  
 @see [PMBannerAdViewDelegate bannerAdView:shouldSaveCalendarEvent:inEventStore:]
 
 @param adView The PMBannerAdView instance sending the message.
 @return `NO` Informs richmedia ads that calendar access is not supported.
 @return `YES` Informs richmedia ads that calendar access is supported.
 */
- (BOOL)bannerAdViewSupportsCalendar:(PMBannerAdView*)adView;


/*! Sent to allow developers to override picture storing support.
 
 Implement to indicate if storing pictures is supported. The default behavior is to NOT allow storing
 of pictures.
 
 @see [PMBannerAdViewDelegate PMBannerAdView:shouldSavePhotoToCameraRoll:]
 
 @param adView The PMBannerAdView instance sending the message.
 @return `NO` Informs richmedia ads that storing pictures is not supported.
 @return `YES` Informs richmedia ads that storing pictures is supported.
 */
- (BOOL)bannerAdViewSupportsStorePicture:(PMBannerAdView*)adView;

/*! Sent when an ad desires to play a video in an external player.
 
 The default is to open the URL and play the video.
 
 Developers can use an application player and return NO to play the video directly.
 
 @param adView The PMBannerAdView instance sending the message.
 @param videoURL The URL string of the video to play.
 @return `NO` Do not open the URL and play the video.
 @return `YES` Invoke UIApplication openURL: to play the video.
 */
- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldPlayVideo:(NSString*)videoURL;


/*! Sent when a richmedia ad attempts to create a new calendar entry.
 
 Application developers can implement the dialog directly if desired by capturing the event
 and eventStore and returning `nil`.  If not implemented the SDK will ignore the request.
 
 @param adView The PMBannerAdView instance sending the message.
 @param event The event to save.
 @param eventStore the store to save the event too.
 @return `NO` Do not attempt to add the calendar event.
 @return `YES` Present the calendar event editor to the user to allow them to edit and save or cancel the event.
 */
- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldSaveCalendarEvent:(EKEvent*)event inEventStore:(EKEventStore*)eventStore;


/*! Sent when a richmedia ad attempts to save a picture to the camera roll.
 
 Application developers should implement this by prompting the user to save the image and then saving
 it directly and returning NO from this delegate method.  If not implemented the image will NOT be
 saved to the camera roll.
 
 Note: iOS 6 added privacy options for applications saving to the camera roll.  The user will be
 prompted by iOS on the first attempt at accessing the camera roll.  If the user selects No then
 pictures will not be saved to the camera roll even if this method is implemented and returns `YES`.
 
 @param adView The PMBannerAdView instance sending the message.
 @param image The image to save.
 @return `NO` Do not save the image to the camera roll.
 @return `YES` Attempt to save the image to the camera roll.
 */
- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldSavePhotoToCameraRoll:(UIImage*)image;


/*! Sent after the SDK process a richmedia event.
 
 Applications can use this to react to various events if necessary but the SDK will have
 already processed them as necessary (expanded in result of an expand request).
 
 @warning Developers should not attempt to implement the specified event.  The SDK will
 have already processed the event with the SDK implementation.
 
 See the IAB MRAID 2 specification on the event types.
 
 @param adView The PMBannerAdView instance sending the message.
 @param event The NSURLRequest containing the event request.
 */
- (void)bannerAdView:(PMBannerAdView *)adView didProcessRichmediaRequest:(NSURLRequest*)event;


/*! Sent to allow the application to override the controller used to present modal controllers.
 
 The SDK by default will use the application's rootViewController property to display modal dialogs.
 These include richmedia expand, internal browser and calendar event creation.  To override using
 this controller implement this message and return the view controller that can be used to present
 modal view controllers.
 
 Note: Application's SHOULD have a rootViewController set but the iOS SDK will allow an application
 to run without one.  If the application can not set up the rootViewController as expected then this
 method MUST be implemented to return a view controller that can be used to present modal dialogs.
 Without one certain SDK features will not work including richmedia expand and
 the internal browser.
 
 @param adView The PMBannerAdView instance sending the message.
 @return UIViewController to use as the presenting view controller for any SDK modal view controller.
 */
- (UIViewController*)bannerAdViewPresentationController:(PMBannerAdView*)adView;


/*! Sent to allow the application to override the superview used for ad resizing and visibility.
 
 The supplied view MUST be a superview in the hierarchy to the PMBannerAdView instance.
 
 The SDK by default will attempt to find a suitable default using the PMBannerAdView instance's window's
 rootViewController view, the application's keyWindow rootViewController's view and finally the
 PMBannerAdView's superview.
 
 Note: Application's SHOULD have a rootViewController set for the application window but the iOS SDK
 will allow an application to run without one.  If the application can not set up the rootViewController
 as expected then this method MUST be implemented to return a view controller that can be used for
 resizing.  Without one set the resize feature may not work correctly.
 
 @param adView The PMBannerAdView instance sending the message.
 @return UIView to use as the superview when placing the resize view container.
 */
- (UIView*)bannerAdViewResizeSuperview:(PMBannerAdView*)adView;


@end

#endif /* PMBannerAdViewDelegate_h */
