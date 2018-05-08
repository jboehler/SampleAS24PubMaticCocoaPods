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

///
///  PMNativeDataAssetType.h
///

/*! Data asset types
 */
typedef NS_ENUM(NSInteger, PMNativeDataAssetType) {

    /*! Sponsored By message where response should contain the brand name of the sponsor. Value is of type Text
     */
    PMNativeDataAssetTypeSponsored        =   1,
    
    
    /*! Descriptive text associated with the product or text service being advertised. Value is of type Text
     */
    PMNativeDataAssetTypeDescription      =   2,
    
    
    //// Rating of the product being offered to the user. For example an app’s rating in an app store from 0-5.Value will be	number formatted as string
    PMNativeDataAssetTypeRating           =   3,
    
    
    /// Number of social ratings or “likes” of the product being offered to the user. Value will be number formatted as string
    PMNativeDataAssetTypeLikes            =   4,
    
    
    /// Number downloads/installs of this product.  Value will be number formatted as string
    PMNativeDataAssetTypeDownloads        =   5,
    
    
    /// Price for product / app / in-app purchase. Value should include currency symbol in localized format. Value will be number formatted as string
    PMNativeDataAssetTypePrice            =   6,
    
    
    /// Sale price that can be used together with price to indicate a discounted price compared to a regular price. Value should include currency symbol in localized format.	 Value will be number formatted as string
    PMNativeDataAssetTypeSalePrice        =   7,
    
    
    /// Represents Phone number of user. Value will be string
    PMNativeDataAssetTypePhone            =   8,
    
    
    /// Represents Address of user. Value will be Text
    PMNativeDataAssetTypeAddress          =   9,
    
    
    /// Additional descriptive text associated with the product or service being advertised. Value will be Text
    PMNativeDataAssetTypeDescription2     =   10,
    
    
    /// Display URL for the text ad. Value will be Text
    PMNativeDataAssetTypeDisplayURL       =   11,
    
    
    /// CTA description - descriptive text describing a ‘call to action’ button for the destination URL.	Value will be Text
    PMNativeDataAssetTypeCTAText          =   12
    
};

typedef NS_ENUM(NSInteger, PMNativeImageAssetType) {
    
    /// Icon image to rendered in native Ad
    PMNativeImageAssetTypeIcon        =   1,
    
    
    /// Logo image to rendered in native Ad
    PMNativeImageAssetTypeLogo        =   2,
    
    
    /// Main image to rendered in native Ad
    PMNativeImageAssetTypeMain        =   3
    
} ;
