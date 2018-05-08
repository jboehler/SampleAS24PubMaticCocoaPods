/*
 
 PubMatic Inc. ("PubMatic") CONFIDENTIAL
 
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
#import "PMSDKUtil.h"
#import "FoundationCategories.h"
#import "PMConstants.h"
#import "PMAdRequest.h"
#import <CoreLocation/CoreLocation.h>
#import "PMError.h"

NSString * RefreshedQueryParams(PMAdRequest * adRequest){

    NSMutableString * params = [NSMutableString new];
    PMSDKUtil *util = [PMSDKUtil sharedInstance];
    //Don't prepend '&' in format for 1st parameter.
    [params appendFormat:@"%@=%@",kLimitAdTrackingParam,util.limitAdTracking];
    [params appendFormat:@"&%@=%@",kDoNotTrackParam,util.limitAdTracking];
    [params appendFormat:@"&%@=%@",kNetworkType,util.netType];
    [params appendFormat:@"&%@=%@",kRanreq,@(util.ranreq).stringValue];
    [params appendFormat:@"&%@=%@",kkltstamp,[util.currentTime urlencode]];
    [params appendFormat:@"&%@=%@",kDeviceOrientationParam,@([util deviceOrientation]).stringValue];
    
    
    BOOL isIDFAEnabled = (adRequest.isIDFAEnabled && ![util limitAdTrackingEnabled]);
    NSString * udidValue = isIDFAEnabled?[util advertisingID]:[util vendorID];
    if (adRequest.udidHashType == PMUdidhashTypeSHA1) {
        udidValue = [udidValue hashUsingSHA1];
    }else if(adRequest.udidHashType == PMUdidhashTypeMD5) {
        udidValue = [udidValue hashUsingMD5];
    }
    [params appendFormat:@"&%@=%@",kUdidParam,udidValue];
    [params appendFormat:@"&%@=%@",kUdidTypeParam,@([util pubDeviceIDTypeForIDFAFlag:isIDFAEnabled]).stringValue];
    
    CLLocation * location = adRequest.location;
    PMLocSource source = adRequest.locationSource;
    if (location) {
        source = PMLocSourceUserProvided;
    }
    if(util.isAutoLocationDetectionAllowed && (util.latitude && util.longitude)){
        
        location = [[CLLocation alloc] initWithLatitude:[util.latitude floatValue] longitude:[util.longitude floatValue]];
        source = PMLocSourceGPS;
    }
   
    if (location){
        
        [params appendFormat:@"&%@=%@,%@",kLocParam,@(location.coordinate.latitude).stringValue,@(location.coordinate.longitude).stringValue];
        [params appendFormat:@"&%@=%ld",kLocSourceParam,(long)source];
    }
    
    return [NSString stringWithString:params];
}

NSMutableURLRequest * nsMutableURLRequest(NSString * url){
    
    return [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kAdTimeoutInterval];

}

NSMutableURLRequest * AdRequestForURL(NSString * url,NSString * postString){
    
    PMSDKUtil *util = [PMSDKUtil sharedInstance];
    NSMutableURLRequest *mRequest = nsMutableURLRequest(url);
    
    if (postString) {
        [mRequest setHTTPMethod:kHTTPPOSTMETHOD];

        NSData * postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
        if(postData != nil ){
            [ mRequest setHTTPBody:postData];
        }
        [mRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type" ];

    }else{
        [mRequest setHTTPMethod:kHTTPGETMETHOD];
    }
    [mRequest setValue:util.userAgent forHTTPHeaderField:kUserAgent];
    return mRequest;
}

NSMutableURLRequest * hbAdRequestForURL(NSString * url,NSData * postData){
    
    PMSDKUtil *util = [PMSDKUtil sharedInstance];
    NSMutableURLRequest *mRequest = nsMutableURLRequest(url);
    
    [mRequest setHTTPMethod:kHTTPPOSTMETHOD];
    [mRequest setValue:kContentTypeValue forHTTPHeaderField:kContentType];
    [mRequest setValue:util.userAgent forHTTPHeaderField:kUserAgent];
    if(postData != nil ){
        [ mRequest setHTTPBody:postData];
    }
    return mRequest;
}

PMError * checkForOKResponse(NSURLResponse *response){
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    
    if(httpResponse.statusCode >= 500 && httpResponse.statusCode < 600 ){
        
        return [PMError errorWithCode:kPMErrorServerError description:[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
        
    }
    
    if (httpResponse.statusCode != 200){
        
        return [PMError errorWithCode:kPMErrorNetworkError description:[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
        
    }
    
    return nil;
}
