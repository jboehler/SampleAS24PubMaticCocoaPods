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

#define kPubMaticBidTag       @"PubMatic_Bid"
#define kErrorCode           @"error_code"
#define kErrorMessage        @"error_string"

#import "PMBannerRRFormatter.h"
#import "PMAdResponse.h"
#import "PMAdDescriptor.h"
#import "PMLogger.h"
#import "PMSDKUtil.h"
#import "PMConstants.h"
#import "PMBaseAdRequestPrivate.h"
#import "FoundationCategories.h"
#import "PMError.h"

#define kBannerAdWidthParam @"ad_width"
#define kBannerAdHeightParam @"ad_height"

@interface PMBannerRRFormatter ()
@property (nonatomic) NSString * subQueryString;
@end

@implementation PMBannerRRFormatter

-(NSURLRequest *)formatRequest:(PMBannerAdRequest *)adRequest{
    
    if (!self.subQueryString) {
        
        NSMutableDictionary * paramsDictionary = adRequest.extraInfoDictionary;
        
        if (![adRequest isKindOfClass:[PMBannerAdRequest class]] && CGSizeEqualToSize(adRequest.adSize, CGSizeZero)){
            
            NSString * adWidth = [paramsDictionary popObjetForKey:kBannerAdWidthParam];
            NSString * adHeight = [paramsDictionary popObjetForKey:kBannerAdHeightParam];
            adRequest.adSize = CGSizeMake(adWidth.floatValue, adHeight.floatValue);
        }else{
            [paramsDictionary popObjetForKey:kBannerAdWidthParam];
            [paramsDictionary popObjetForKey:kBannerAdHeightParam];
        }
        
        [paramsDictionary addEntriesFromDictionary:[adRequest paramsDictionary]];
        
        NSString * paramsString= [paramsDictionary queryStringWithEncoding];        
        self.subQueryString = paramsString;
    }
    
    NSString * serverURL = [NSString stringWithFormat:@"%@?%@&%@&%@=%@&%@=%@",
                            adRequest.adServerURL,
                            self.subQueryString,
                            RefreshedQueryParams(adRequest),
                            kAdWidthParam,@((int)adRequest.adSize.width).stringValue,
                            kAdHeightParam,@((int)adRequest.adSize.height).stringValue];
    
    InfoLog(@"URL - %@",serverURL);
    return AdRequestForURL(serverURL,nil);
}

-(PMAdResponse *)formatResponse:(NSData *)responseData{
    
    PMAdResponse * adResponse = [PMAdResponse new];
    adResponse.rawResponse = responseData;
    NSError* error = nil;
    NSDictionary* jsonD = [NSJSONSerialization
                           JSONObjectWithData:responseData
                           options:kNilOptions
                           error:&error];
    if(error){
        
        adResponse.error = [PMError errorWithCode:kPMErrorInvalidResponse description:error.localizedDescription];
        
    }else{
        
        NSDictionary *parsedAdData = jsonD;
        InfoLog(parsedAdData.description);
        NSDictionary *pubmaticBidDict = [parsedAdData objectForKey:kPubMaticBidTag];
        NSString *errorCode   = [ pubmaticBidDict objectForKey:kErrorCode ];
        NSString *errorMessage= [ pubmaticBidDict objectForKey:kErrorMessage ];
        
        id height = [pubmaticBidDict objectForKey:@"h"];
        id width = [pubmaticBidDict objectForKey:@"w"];
        
        if ( errorCode != nil ){
            
            adResponse.error = [PMError errorWithCode:kPMErrorNoAds description:errorMessage];
            
        }else{
            
            PMAdDescriptor* ad = [[PMAdDescriptor alloc] initWithJSONAttributes:pubmaticBidDict];
            if (([height isKindOfClass:[NSNumber class]] || [height isKindOfClass:[NSString class]]) && ([width isKindOfClass:[NSNumber class]] || [width isKindOfClass:[NSString class]])) {
                
                ad.adSize = CGSizeMake([height floatValue], [width floatValue]);
            }
            
            adResponse.renderable = ad;
        }
    }
    return adResponse;
}

@end
