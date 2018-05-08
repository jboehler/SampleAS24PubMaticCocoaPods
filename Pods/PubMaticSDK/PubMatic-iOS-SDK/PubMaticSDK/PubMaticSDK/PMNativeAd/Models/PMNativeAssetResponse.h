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
#import "PMNativeAssetTypes.h"

@interface PMNativeAssetResponse : NSObject

/*!
  @abstract Unique asset ID, assigned by exchange.
 */
@property(nonatomic,assign) NSInteger assetId;

@end

@interface PMNativeDataAssetResponse : PMNativeAssetResponse

/*!
  @abstract Represents data value.
 */
@property(nonatomic,strong) NSString* value;

/*!
 @abstract Type of the data asset as defined in enum PMNativeDataAssetType.
  @discussion Type of the data asset as defined in enum PMNativeDataAssetType.
 Possible values are :
 
 - PMNativeDataAssetTypeSponsored,
 - PMNativeDataAssetTypeDescription,
 - PMNativeDataAssetTypeRating,
 - PMNativeDataAssetTypeLikes,
 - PMNativeDataAssetTypeDownloads,
 - PMNativeDataAssetTypePrice,
 - PMNativeDataAssetTypeSalePrice,
 - PMNativeDataAssetTypePhone,
 - PMNativeDataAssetTypeAddress,
 - PMNativeDataAssetTypeDescription2,
 - PMNativeDataAssetTypeDisplayURL,
 - PMNativeDataAssetTypeCTAText
 
 @see PMNativeDataAssetType
 */
@property(nonatomic,assign) PMNativeDataAssetType subtype;

- (instancetype)initWithId:(NSInteger )assetId withValue:(NSString*)value;


@end


@interface PMNativeImageAssetResponse : PMNativeAssetResponse

/*!
  @abstract Integer	Maximal width of the image in pixels.
 */
@property(nonatomic,assign) NSInteger width;


/*!
  @abstract Integer	Maximal height of the image in pixels.
 */
@property(nonatomic,assign) NSInteger height;


/*!
  @abstract NSURL Represents url from where image is to be downloaded.
 */
@property(nonatomic,strong) NSURL *imageURL;

/*!
  @abstract Integer	Type of the image. Possible values:
 
 - PMNativeImageAssetTypeIcon,
 - PMNativeImageAssetTypeLogo,
 - PMNativeImageAssetTypeMain
 
 @see PMNativeImageAssetType
 */
@property(nonatomic,assign) PMNativeImageAssetType subtype;


- (instancetype)initWithId:(NSInteger )assetId withWidth:(NSInteger )width withHeight:(NSInteger )height andImageURL:(NSString*) imageURL;


@end


 
@interface PMNativeTitleAssetResponse : PMNativeAssetResponse
 
 /*!
  @abstract Represents text value of title
 */
@property(nonatomic,strong) NSString* text;

- (instancetype)initWithId:(NSInteger )assetId withValue:(NSString*)text;

@end

