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

#import "PMBaseAdRequest.h"

// Genders to help deliver more relevant ads.
typedef NS_ENUM(NSInteger, PMGender)  {
    PMGenderOther = 0,
    PMGenderMale,
    PMGenderFemale,
};

//Ad orientation
typedef NS_ENUM(NSInteger, PMADOrientation){
    PMADOrientationPortrait,
    PMADOrientationLandscape
};

//User ethnicity
typedef NS_ENUM(NSInteger, PMEthnicity) {
    PMEthnicityHispanic=0,
    PMEthnicityAfricanAmerican,
    PMEthnicityCaucasian,
    PMEthnicityAsianAmerican,
    PMEthnicityOther
};

/*! Abstract class for PubMatic (SSP) ad requests (e.g. PMBannerAdRequest, PMNativeAdRequest..etc)
 @warning Direct instance of PMAdRequest should not be used to request any Ads
 */
@interface PMAdRequest : PMBaseAdRequest
{
    
}


/*! @name Initialization method */

/*!
 @brief Initialize Ad request with Publisher credentials i.e Publisher Id, Site Id, Ad Id
 @param pubId ID of the publisher. This value can be obtained from the pubId parameter in the PubMatic ad tag.
 @param siteId ID of the publisher's Web site. A publisher can have multiple sites. This value can be obtained from the siteId parameter in the PubMatic ad tag.
 @param adId ID of the ad's placement. A site can have multiple ad placements or positions which have the same or different ad sizes. adId is the unique identifier for such an ad placement and this value can be obtained from the adId parameter in the PubMatic ad tag.
 @return Initialized of Ad Request of concrete class
 */
- (id)initWithPublisherId:(NSString *)pubId siteId:(NSString *)siteId
              adId:(NSString *)adId;

/*! @name Initialization method */

/*!
 Adds custon key-value parameters in Ad request
 @param paramValue value of custom parameter
 @param paramKey parameter name of custom paramter
 */
-(void)setCustomParam:(NSString *)paramValue forKey:(NSString *)paramKey;

/*!
 @abstract Getter for ID of the publisher. This value can be obtained from the pubId parameter in the PubMatic ad tag.
 */
@property (nonatomic, readonly,strong) NSString * publisherId;

/*!
 @abstract Indicates whether Advertisment ID should be sent in the request. Possible values are:
 
 - YES : IDFA will be sent in the request.
 - NO : Vendor ID will be sent in the request instead of the IDFA.
 Default value is YES
 */
@property (nonatomic, assign) BOOL isIDFAEnabled;

/*
 @abstract Apply following hashing on udid before sending to server, Possible values are:
 
 - PMUdidhashTypeRaw,
 - PMUdidhashTypeSHA1,
 - PMUdidhashTypeMD5

 Default is PMUdidhashTypeRaw
 @see PMUdidhashType
 */
@property (nonatomic, assign) PMUdidhashType udidHashType;

/*!
 @abstract Indicates whether the visitor is COPPA-specific or not.
 @discussion For COPPA (Children's Online Privacy Protection Act) compliance, if the visitor's age is below 13, then such visitors should not be served targeted ads.
 Possible options are:
 
 - PMBOOLNo : Indicates that the visitor is not COPPA-specific and can be served targeted ads.
 - PMBOOLYes : Indicates that the visitor is COPPA-specific and should be served only COPPA-compliant ads.
 */
@property (nonatomic, assign) PMBOOL coppa;

/*!
 @discussion Set PMBOOLYes if app is paid & PMBOOLNo if it is free.
 Possible values are:
 
 - PMBOOLNo : Free version
 - PMBOOLYes : Paid version
 */
@property (nonatomic, assign) PMBOOL applicationPaid;

/*!
 @abstract This parameter is used to pass a zone ID for reporting.
 */
@property (nonatomic, strong) NSString * pmZoneId;

/*!
 @abstract Application primary category as displayed on storeurl page for the respective platform.
 */
@property (nonatomic, strong) NSString * appCategory;

/*!
 @abstract IAB category for the application.
 */
@property (nonatomic, strong) NSString * IABCategory;

/*!
@abstract Indicates the domain of the mobile application
 */
@property (nonatomic, strong) NSString * appDomain;

/*! @name User Information */

/*! 
 The user's location source may be useful in delivering geographically relevant ads,if location is provided by
 user of the application, please set this property as PMLocSourceUserProvided, default value of locationSource is
 PMLocSourceUnknown
 Possible options are:
 
 - PMLocSourceUnknown,
 - PMLocSourceGPS,
 - PMLocSourceIPAddress,
 - PMLocSourceUserProvided
 
 @see PMLocSource
 */
@property (nonatomic, assign) PMLocSource locationSource;

/*!
 @abstract User Income if available for more relevant Ads
 */
@property (nonatomic, strong) NSString* userIncome;

/*!
 @abstract The user's state may be useful in delivering geographically relevant ads
 */
@property (nonatomic, strong) NSString* state;

/*!
 The user's ethnicity may be used to deliver more relevant ads.
 Code of ethnicity. 
 Possible options are:
 
 - PMEthnicityHispanic,
 - PMEthnicityAfricanAmerican,
 - PMEthnicityCaucasian,
 - PMEthnicityAsianAmerican,
 - PMEthnicityOther
 
 @see PMEthnicity
 */
@property (nonatomic, assign) PMEthnicity ethnicity;

/*!
 Set the user gender,
 Possible options are:
 
- PMGenderOther
- PMGenderMale,
- PMGenderFemale
 
 @see PMGender
 */
@property (nonatomic, assign) PMGender gender;

/*!
 @abstract iOS application's ID
  */
@property (nonatomic, strong) NSString* aid;
    
/*!
 @abstract The year of Year of birth as a 4-digit integer

    Example :
    adRequest.birthYear = @"1988";
 
 */
@property (nonatomic, strong) NSString* birthYear;

/*!
@abstract URL of application on App store URL
*/
@property (nonatomic, strong) NSString* storeURL;

@end
