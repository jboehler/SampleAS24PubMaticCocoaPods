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
//  PMNativeAd.h
//
//  Created  on 03/07/14.

//

#import "PMNativeAdDelegate.h"
#import "PMNativeAssetRequest.h"
#import "PMNativeAssetResponse.h"
#import "PMNativeAdRequest.h"
#import "PMError.h"

/*!
 The PMNativeAd class used for requesting Native ads from PubMatic
 */
@interface PMNativeAd: NSObject

/*!
 @abstract Issues an request to fetch new native Ad.
 @param adRequest instance of PMNativeAdRequest
 */
-(void)loadRequest:(PMBaseAdRequest *)adRequest;

/*!
 abstract Sets the PMNativeAdDelegate delegate receiver for the PMNativeAd.
 @warning Proper reference management practices should be observed when using delegates.
 @warning Ensure that the delegate is set to nil prior to setting nil to PMNativeAd object reference
 */
@property (nonatomic, weak) id<PMNativeAdDelegate> delegate;

/*!
 When PMNativeAd done with ad fetching from PubMatic server, All requested native ad asstes will be available in adAssetResponseArray. It can contain objects of PMNativeDataAssetResponse, PMNativeImageAssetResponse, PMNativeTitleAssetResponse based on requested assets
 @see PMNativeImageAssetRequest
 @see PMNativeTitleAssetRequest
 @see PMNativeDataAssetRequest
 */
@property (nonatomic,readonly) NSArray<PMNativeAssetResponse *> * adAssetResponseArray;

/** Set to enable the use of the internal browser for opening ad content.  Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL useInternalBrowser;

/*!
 Method to be called once native ad is sucessfully rendered for sending sucess metric url
 and hence handling user clicks
 @param view Native Ad View where all native ad components are rendered
 @param viewController Viewcontroller on which native ad is placed
 */
-(void)trackViewForInteractions:(UIView*)view withViewController:(UIViewController* )viewController;

/*!
 Method will asyncronously download and hence render image in imageView. This method can be used for rendering icon and cover image
 @param imageView Image View where image is to be rendered
 @param urlString URL of image which is to be rendered
 */
-(void) loadInImageView:(UIImageView *)imageView withURL:(NSString *) urlString;

/*!
Method will be used to destroy instance of native ad and hence free resources.
This method is to be called only when native ad is supposed to be deallocated.
 */
-(void) destroy;

@end

