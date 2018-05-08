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

#import <UIKit/UIKit.h>

static const CGSize PMBANNER_SIZE_320x50  = {320, 50};
static const CGSize PMBANNER_SIZE_300x50  = {300, 50};
static const CGSize PMBANNER_SIZE_300x250  = {300,250};
static const CGSize PMBANNER_SIZE_38x38  = {38, 38};

static const CGSize PMBANNER_SIZE_320x416  = {320, 416};
static const CGSize PMBANNER_SIZE_320x100  = {320, 100};
static const CGSize PMBANNER_SIZE_320x53  = {320, 53};
static const CGSize PMBANNER_SIZE_480x32  = {480, 32};

static const CGSize PMBANNER_SIZE_768x66  = {768, 66};
static const CGSize PMBANNER_SIZE_768x90  = {768, 90};
static const CGSize PMBANNER_SIZE_728x90  = {728, 90};
static const CGSize PMBANNER_SIZE_1024x90  = {1024, 90};
static const CGSize PMBANNER_SIZE_1024x66  = {1024, 66};
static const CGSize PMBANNER_SIZE_160x600  = {160, 600};
static const CGSize PMBANNER_SIZE_120x60  = {120, 60};
static const CGSize PMBANNER_SIZE_555x206  = {555, 206};
static const CGSize PMBANNER_SIZE_500x500  = {500, 500};
static const CGSize PMBANNER_SIZE_250x250  = {250, 250};
static const CGSize PMBANNER_SIZE_216x36  = {216, 36};
static const CGSize PMBANNER_SIZE_210x175  = {210, 175};
static const CGSize PMBANNER_SIZE_200x120  = {200, 120};
static const CGSize PMBANNER_SIZE_185x30  = {185, 30};
static const CGSize PMBANNER_SIZE_168x28  = {168, 28};
static const CGSize PMBANNER_SIZE_120x20  = {120, 20};

#import "PMAdRequest.h"

/*! PMBannerAdRequest class provides properties for ad request parameters. To request Banner Ad, you need to pass valid PMBannerAdRequest instance to PMBannerAdView's loadRequest: method.
 */
@interface PMBannerAdRequest : PMAdRequest

/*!
 Size of Banner ad, It is mandatory parameter
 It can be set as any appropriate CGSize value or from pre-defined values below
 PMBANNER_SIZE_320x50, PMBANNER_SIZE_300x50, PMBANNER_SIZE_300x250
 PMBANNER_SIZE_38x38, PMBANNER_SIZE_320x416, PMBANNER_SIZE_320x100
 */
@property (nonatomic,assign) CGSize adSize;

/*!
 Ad orientation. Possible values are:

 - PMADOrientationPortrait : Portrait orientation
 - PMADOrientationLandscape : Landscape orientation
 
 @see PMADOrientation
 */
@property (nonatomic,assign)  PMADOrientation  adOrientation;

/**
 Optional Ad sizes that can be set along with adSize.

    Example:
    request.optionalAdSizes = @[[NSValue valueWithCGSize:CGSizeMake(300, 50)],[NSValue valueWithCGSize:CGSizeMake(320, 50)]]

 @note Maximum first 4 sizes would be considered at server for DSP auctioning.
 */
@property (nonatomic,strong)  NSArray <NSValue * >* optionalAdSizes;

@end
