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


#ifndef PMConstants_h
#define PMConstants_h
#import <Foundation/Foundation.h>


#define PM_SERVER_URL            @"http://showads.pubmatic.com/AdServer/AdServerServlet"
#define PM_SECURE_SERVER_URL     @"https://showads.pubmatic.com/AdServer/AdServerServlet"

// POST Parameters
#define kOperIdParam             @"operId"
#define kPubIdParam              @"pubId"
#define kSiteIdParam             @"siteId"
#define kAdIdParam               @"adId"
#define kJsParam                 @"js"
#define kTimezoneParam           @"timezone"
#define kScreenResolutionParam   @"screenResolution"
#define kUdidParam               @"udid"
#define kUdidTypeParam           @"udidtype"
#define kUdidHashParam           @"udidhash"
#define kMakeParam               @"make"
#define kModelParam              @"model"
#define kLocParam                @"loc"
#define kNetworkType             @"nettype"
#define kRanreq                  @"ranreq"
#define kkltstamp                @"kltstamp"
#define kCarrierParam            @"carrier"
#define kAppName                 @"name"
#define kAppPaid                 @"paid"
#define kAppStoreUrl             @"storeurl"
#define kAppID                   @"aid"
#define kVerParam                @"ver"
#define kAPIParam                @"api"
#define kCoppaParam              @"coppa"
#define kAwt                     @"awt"
#define kPMZoneIDParam           @"pmZoneId"

// Request timedout interval
#define kOperIdValue        201
// HTTP header parameters
#define kUserAgent              @"User-Agent"

// POST Parameters
#define kPageURLParam            @"pageURL"
#define kInIframeParam           @"inIframe"
#define kInIframeParamValue      @"0"
#define kCountryParam            @"country"
#define kOsParam                 @"os"
#define kOsvParam                @"osv"
#define kAppDomain               @"appdomain"
#define kAppCat                  @"cat"
#define kBundleParam             @"bundle"

/*
 List of supported API frameworks for this impression. If an API is not explicitly listed, then it is assumed to be not supported.
 
 If an application supports multiple API frameworks, you can send the multiple framework values separated by ::  and URL encoded string.
 
 For example, api=3%3A%3A4%3A%3A5
 Value
 Description
 3 - MRAID 1.0
 4 - ORMMA
 5 - MRAID 2.0
 */

#define kAPIParamValue           @"3::4::5"

#define kLimitAdTrackingParam    @"lmt"
#define kDoNotTrackParam         @"dnt"

#define kDeviceOrientationParam  @"deviceOrientation"
#define kYobParam                @"yob"
#define kGenderParam             @"gender"
#define kLocSourceParam          @"loc_source"
#define kZipParam                @"zip"
#define kStateParam              @"state"
#define kCityParam               @"city"
#define kDMAParam                @"dma"
#define kKeywordsParam           @"keywords"
#define kSDK_IdParam             @"msdkId"
#define kDCTR_Param              @"dctr"
#define kSDK_VerParam            @"msdkVersion"
#define kLanguage                @"lang"
#define kAreaCodeParam           @"area"
#define kUserIncome              @"inc"
#define kUserEthnicity           @"ethn"


#define kAdTimeoutInterval      5.0
#define kHTTPGETMETHOD          @"GET"
#define kHTTPPOSTMETHOD         @"POST"
#define kUserAgent              @"User-Agent"
#define kContentType            @"Content-Type"
#define kContentTypeValue       @"application/json"

#define kAdWidthParam            @"kadwidth"
#define kAdHeightParam           @"kadheight"
#define kAdPositionParamDefaultValue         @"-1x-1"
#define kAdOrientationParam      @"adOrientation"
#define kAdPositionParam         @"adPosition"
#define kAdTypeParam             @"adtype"
#define kBannerAdTypeParamValue  @"11"
#define kInterstitialAdTypeParamValue  kBannerAdTypeParamValue
#define kInterstitialParam       @"instl"

/*!
 Indicates whether the tracking URL has been wrapped or not in the creative tag.
 Possible options are:
 0 - Indicates that the tracking URL is sent separately in the response JSON as tracking_url. In this case, the tracking_url field is absent in the JSON response.
 1 - Indicates that the tracking_url value is wrapped in an Iframe and appended to the creative_tag.
 2 - Indicates that the tracking_url value is wrapped in a JS tag and appended to the creative_tag.
 Note:
 If the awt parameter is absent in the bid request URL, then it is same as awt=0 mentioned above.
 Its default value is 0.
 */
typedef NS_ENUM(NSInteger, PMAWT) {
    PMAWTSeparateTracker,
    PMAWTiframeEmbeddedTracker,
    PMAWTJSEmbeddedTracker
};

@class PMAdRequest;
@class PMError;

NSString * RefreshedQueryParams(PMAdRequest * adRequest);
NSMutableURLRequest * AdRequestForURL(NSString * url,NSString * postString);
NSMutableURLRequest * hbAdRequestForURL(NSString * url,NSData * postData);
PMError * checkForOKResponse(NSURLResponse *response);

#endif /* PMConstants_h */
