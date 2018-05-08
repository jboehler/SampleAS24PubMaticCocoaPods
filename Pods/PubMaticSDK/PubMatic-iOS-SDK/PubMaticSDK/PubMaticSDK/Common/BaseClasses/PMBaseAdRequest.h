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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PMBOOL) {
    PMBOOLNo = 0,
    PMBOOLYes
};

typedef NS_ENUM(NSInteger, PMLocSource)  {
    
    PMLocSourceUnknown,
    PMLocSourceGPS,
    PMLocSourceIPAddress,
    PMLocSourceUserProvided
    
};

typedef NS_ENUM(NSInteger, PMUdidhashType) {
    PMUdidhashTypeRaw=1,
    PMUdidhashTypeSHA1,
    PMUdidhashTypeMD5
};

@class PMAdResponse,PMBaseAdRequest,CLLocation;

@protocol PMResponseGenerator <NSObject>

- (NSDictionary*)prefetchedResponseForImpressionId:(NSString*)impressionId;

@end

@protocol PMAdRenderer <NSObject>

- (void)renderWithPrefetcher:(id<PMResponseGenerator>)prefetcher forImpressionId:(NSString*)impressionId andRequest:(PMBaseAdRequest *)adRequest;

@end


/*! 
 Abstract class for All types of ad requests (e.g. PMBannerAdRequest, PMNativeAdRequest..etc)
 @warning Direct instance of PMBaseAdRequest should not be used to request any Ads
 */
@interface PMBaseAdRequest : NSObject

/*!
 @abstract Requests secure ads from ad server, This feature is added for Apple's App Transport Security(ATS) support.
 */
@property (nonatomic, assign) BOOL requestSecureCreative;

/*!
 @abstract The user's location useful in delivering geographically relevant ads
 
     Example :
     adRequest.location = [[CLLocation alloc] initWithLatitude:18.563 longitude:73.77];

 */
@property (nonatomic, strong) CLLocation * location;

/// @abstract City of user
@property (nonatomic, strong) NSString* city ;

/*!
@abstract You can set Designated market area (DMA) code of the user in this field.
This field is applicable for US users only
*/
@property (nonatomic, strong) NSString* dma;

/// @abstract The user's zipcode may be useful in delivering geographically relevant ads
@property (nonatomic, strong) NSString* zip;

/*!
 @abstract A comma-separated list of keywords indicating the consumer's interests or intent.
 */
@property (nonatomic, strong) NSString* keywords;

@end
