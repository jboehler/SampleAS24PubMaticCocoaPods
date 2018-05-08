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

#import <UIKit/UIKit.h>
#import "PMMRAIDProperties.h"


@class PMMRAIDBridge;

typedef NS_ENUM(NSInteger, PMMRAIDBridgeState) {
    PMMRAIDBridgeStateLoading = 0,
    PMMRAIDBridgeStateDefault,
    PMMRAIDBridgeStateExpanded,
    PMMRAIDBridgeStateResized,
    PMMRAIDBridgeStateHidden
};

typedef NS_ENUM(NSInteger, PMMRAIDBridgePlacementType) {
    PMMRAIDBridgePlacementTypeInline = 0,
    PMMRAIDBridgePlacementTypeInterstitial,
};

typedef NS_ENUM(NSInteger, PMMRAIDBridgeSupports) {
    PMMRAIDBridgeSupportsSMS = 0,
    PMMRAIDBridgeSupportsTel,
    PMMRAIDBridgeSupportsCalendar,
    PMMRAIDBridgeSupportsStorePicture,
    PMMRAIDBridgeSupportsInlineVideo
};


@protocol PMMRAIDBridgeDelegate <NSObject>
@required

- (void)mraidBridgeInit:(PMMRAIDBridge*)bridge;

- (void)mraidBridgeClose:(PMMRAIDBridge*)bridge;

- (void)mraidBridge:(PMMRAIDBridge*)bridge openURL:(NSString*)url;

- (void)mraidBridgeUpdateCurrentPosition:(PMMRAIDBridge*)bridge;

- (void)mraidBridgeUpdatedExpandProperties:(PMMRAIDBridge*)bridge;

- (void)mraidBridge:(PMMRAIDBridge*)bridge expandWithURL:(NSString*)url;

- (void)mraidBridgeUpdatedOrientationProperties:(PMMRAIDBridge *)bridge;

- (void)mraidBridgeUpdatedResizeProperties:(PMMRAIDBridge *)bridge;

- (void)mraidBridgeResize:(PMMRAIDBridge*)bridge;

- (void)mraidBridge:(PMMRAIDBridge*)bridge playVideo:(NSString*)url;

- (void)mraidBridge:(PMMRAIDBridge*)bridge createCalenderEvent:(NSString*)event;

- (void)mraidBridge:(PMMRAIDBridge*)bridge storePicture:(NSString*)url;

@end


@interface PMMRAIDBridge : NSObject

@property (nonatomic, assign) id<PMMRAIDBridgeDelegate> delegate;

@property (nonatomic, assign) BOOL needsInit;

@property (nonatomic, readonly) PMMRAIDBridgeState state;
@property (nonatomic, readonly) PMMRAIDExpandProperties* expandProperties;
@property (nonatomic, readonly) PMMRAIDResizeProperties* resizeProperties;
@property (nonatomic, readonly) PMMRAIDOrientationProperties* orientationProperties;


- (void)sendErrorMessage:(NSString*)message forAction:(NSString*)action forWebView:(UIWebView*)webView;
- (void)setSupported:(BOOL)supported forFeature:(PMMRAIDBridgeSupports)feature forWebView:(UIWebView*)webView;
- (void)setState:(PMMRAIDBridgeState)state forWebView:(UIWebView*)webView;
- (void)sendReadyForWebView:(UIWebView*)webView;
- (void)setViewable:(BOOL)viewable forWebView:(UIWebView*)webView;
- (void)setScreenSize:(CGSize)screenSize forWebView:(UIWebView*)webView;
- (void)setMaxSize:(CGSize)maxSize forWebView:(UIWebView*)webView;
- (void)setCurrentPosition:(CGRect)currentPosition forWebView:(UIWebView*)webView;
- (void)setDefaultPosition:(CGRect)defaultPosition forWebView:(UIWebView*)webView;
- (void)setPlacementType:(PMMRAIDBridgePlacementType)placementType forWebView:(UIWebView*)webView;
- (void)setExpandProperties:(PMMRAIDExpandProperties*)expandProperties forWebView:(UIWebView*)webView;
- (void)setResizeProperties:(PMMRAIDResizeProperties*)resizeProperties forWebView:(UIWebView*)webView;
- (void)setOrientationProperties:(PMMRAIDOrientationProperties*)orientationProperties forWebView:(UIWebView*)webView;
- (void)sendPictureAdded:(BOOL)success forWebView:(UIWebView*)webView;


// Call when UIWebView (MRAID container) loads a request.
// Returns TRUE if the request was for MRAID, false if it's some other request.
- (BOOL)parseRequest:(NSURLRequest*)request;

@end
