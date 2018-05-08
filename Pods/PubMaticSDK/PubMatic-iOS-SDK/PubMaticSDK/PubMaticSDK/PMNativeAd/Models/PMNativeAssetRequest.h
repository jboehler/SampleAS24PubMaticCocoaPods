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
//  PMNativeAsset.h
//   PMBannerAdView 
//

#import <Foundation/Foundation.h>
#import "PMNativeAssetRequest.h"
#import "PMNativeAssetTypes.h"



@interface PMNativeAssetRequest : NSObject

/*!
  @abstract Unique asset ID
 */
@property(nonatomic,assign,readonly) NSInteger assetId;

/*!
  @abstract Set to 1 if the asset is required. Default value is 0 (optional).
 */
@property(nonatomic,assign) NSInteger required;

/*!
  @abstract Asset type. Possible values: “title”, “img”, “data”. Its value is automatically set on creating specific instance of derived class
 */
@property(nonatomic,strong) NSString *type;

/*!
  @abstract Set to 1 if the asset is required. Default value is 0 (optional).
 */
@property(nonatomic,strong) NSMutableDictionary* entityDictionary;

-(NSMutableDictionary *) getJSONDictionary;

@end


@interface PMNativeDataAssetRequest : PMNativeAssetRequest

-(instancetype)init __attribute__((unavailable("This method is not available, Use initWithId:subtype: instead")));

/*
 PMNativeImageAssetRequest initialization method, this object should be intialized using this method to create valid object
 @param assetId
 @param subtype PMNativeDataAssetType value
  @param length Maximal length of the data value.
 */
-(instancetype)initWithId:(NSInteger)assetId
                     subtype:(PMNativeDataAssetType)subtype
                   length:(NSInteger)length;

/*
 PMNativeImageAssetRequest initialization method, this object should be intialized using this method to create valid object
 @param assetId
 @param subtype PMNativeDataAssetType value
 */
-(instancetype)initWithId:(NSInteger)assetId
                  subtype:(PMNativeDataAssetType)subtype;

/*!
 Type of the data asset as defined in enum PMNativeDataAssetType.
 */
@property(nonatomic,assign) PMNativeDataAssetType subtype;

/*!
  @abstract Maximal length of the data value.
 */
@property(nonatomic,assign) NSInteger length;

@end


@interface PMNativeImageAssetRequest : PMNativeAssetRequest

-(instancetype)init __attribute__((unavailable("This method is not available, Use initWithId:type:width:height instead")));

/*
 
 PMNativeImageAssetRequest initialization method, this object should be intialized using this method to create valid object
 @param assetId asset id
 @param subtype PMNativeImageAssetType value
 @param width Maximal width of the image in pixels.
 @param height Maximal height of the image in pixels.
 */
-(instancetype)initWithId:(NSInteger)assetId
                     subtype:(PMNativeImageAssetType)subtype
                    width:(NSInteger)width
                   height:(NSInteger)height;

/*!
  @abstract PMNativeImageAssetType value
 */
@property(nonatomic,assign,readonly) PMNativeImageAssetType subtype;


/*!
  @abstract Integer	Maximal width of the image in pixels.
 */
@property(nonatomic,assign,readonly) NSInteger width;


/*!
  @abstract Integer	Maximal height of the image in pixels.
 */
@property(nonatomic,assign,readonly) NSInteger height;


/*!
  @abstract Integer	Minimal width of the image in pixels.
 */
@property(nonatomic,assign) NSInteger minimumWidth;

/*!
  @abstract Integer	Minimal height of the image in pixels.
 */
@property(nonatomic,assign) NSInteger minimumHeight;

/*!
  @abstract List of mime types for this image asset as per IAB standard.
 */
@property(nonatomic,strong) NSArray *mimeTypes;

@end



@interface PMNativeTitleAssetRequest : PMNativeAssetRequest

-(instancetype)init __attribute__((unavailable("This method is not available, Use initWithId:length instead")));

/*!
 PMNativeTitleAssetRequest initialization method, this object should be intialized using this method to create valid object
 @param assetId Identifier for asset
 @param lenght lenght of title
 */
-(instancetype)initWithId:(NSInteger)assetId length:(NSInteger)lenght;


@end

