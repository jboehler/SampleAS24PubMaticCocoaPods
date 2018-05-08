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
#import "PMAdRequest.h"
#import "PMNativeAssetRequest.h"

/*!
 Ad Request class for making Native ad from PubMatic (SSP)
 */
@interface PMNativeAdRequest : PMAdRequest

/*!
  @abstract Native ad assets array
 
 Returns array of following class intances :
 
 - PMNativeTitleAssetRequest
 - PMNativeImageAssetRequest
 - PMNativeDataAssetRequest
 
 */
@property (nonatomic,readonly)  NSMutableArray *adAssetArray;

/*!
 @abstract Adds instance of below classes on PMNativeAdRequest
 
 - PMNativeTitleAssetRequest
 - PMNativeImageAssetRequest
 - PMNativeDataAssetRequest
 
When [PMNativeAd loadRequest:] is called with PMNativeAdRequest instance, Asset responses of below types will be available in [PMNativeAd adAssetResponseArray].
 
 - PMNativeTitleAssetResponse
 - PMNativeImageAssetResponse
 - PMNativeDataAssetResponse
 
 @warning Access [PMNativeAd adAssetResponseArray] only after successful Native Ad is received i.e. [PMNativeAdDelegate nativeAdDidRecieveAd:] delegate method is called.

 @see PMNativeDataAssetType, PMNativeImageAssetType
 */
-(BOOL) addAsset:(PMNativeAssetRequest *) nativeAsset;

@end
