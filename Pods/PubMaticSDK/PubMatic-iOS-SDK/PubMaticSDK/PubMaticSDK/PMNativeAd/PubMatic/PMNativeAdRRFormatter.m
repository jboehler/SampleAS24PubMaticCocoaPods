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
#define kErrorCode           @"error_code"
#define kErrorMessage        @"error_string"
#define kCreativeTagKey      @"creative_tag"
#define kPubMatic_BidTag       @"PubMatic_Bid"

#import "PMNativeAdRRFormatter.h"
#import "PMSDKUtil.h"
#import "PMNativeAdRequest.h"
#import "PMResponseParser.h"
#import "PMLogger.h"
#import "PMBaseAdRequestPrivate.h"
#import "FoundationCategories.h"
#import "PMConstants.h"
#import "PMError.h"

@interface PMNativeAdRRFormatter ()
@property (nonatomic) NSString * subQueryString;
@end

@implementation PMNativeAdRRFormatter


-(NSURLRequest *)formatRequest:(PMNativeAdRequest *)adRequest{
    
    if (!self.subQueryString) {
        
        NSMutableArray * nativeAssetArray = [NSMutableArray new];
        for (PMNativeAssetRequest * nativeAsset in adRequest.adAssetArray) {
            
            NSDictionary *dict = [nativeAsset getJSONDictionary];
            [nativeAssetArray addObject:dict];
            
        }
        
        NSMutableDictionary * paramsDictionary = adRequest.extraInfoDictionary;
        [paramsDictionary addEntriesFromDictionary:[adRequest paramsDictionary]];
        
        
        NSMutableDictionary *finalDictionary = [NSMutableDictionary new];
        [finalDictionary setObject:@"1" forKey:@"ver"];
        [finalDictionary setObject:nativeAssetArray forKey:@"assets"];
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalDictionary
                                                           options:0
                                                             error:&error];
        if(error){
            
            ErrorLog(@"Error code: %ld Description: %@", error.code, error.localizedDescription);
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [paramsDictionary setObjectSafely:jsonString forKey:@"native"];
        NSString * postString = [paramsDictionary queryStringWithEncoding];
        self.subQueryString = postString;
    }

    NSString * url = adRequest.adServerURL;
    InfoLog(@"Ad Request URL = %@", url);
    NSString * postString = [NSString stringWithFormat:@"%@&%@",
                             self.subQueryString,
                            RefreshedQueryParams(adRequest)];
    

    InfoLog(@"Ad Request Post Data = %@", postString);
    return AdRequestForURL(url, postString);
}

-(PMAdResponse *)formatResponse:(NSData *)responseData{
    
    PMAdResponse * adResponse = [PMAdResponse new];
    adResponse.rawResponse = responseData;

    // TO be used only for debuging
#ifdef DEBUG
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    InfoLog(@"Response Received : %@",responseString);
#endif

    
    NSError *error = nil;
    
    NSDictionary* jsonD = [NSJSONSerialization
                           JSONObjectWithData:responseData //1
                           
                           options:kNilOptions
                           error:&error];
    
    if(error){
        
        adResponse.error = [PMError errorWithCode:kPMErrorInvalidResponse description:error.localizedDescription];
        
    }else{
        NSDictionary *parsedAdData =jsonD;
        
        // This will do the actual parsing the of the json and stores the json in the form of a dictionary.
        NSDictionary *pubmaticBid = [parsedAdData objectForKey:kPubMatic_BidTag];
        
        // Check for error from the server
        NSString *errorCode   = [ pubmaticBid objectForKey:kErrorCode ];
        NSString *errorMessage= [ pubmaticBid objectForKey:kErrorMessage ];
        
        if ( errorCode != nil )
        {
            adResponse.error = [PMError errorWithCode:kPMErrorNoAds description:errorMessage];
            
        }else{
            
            id creativeObj = [pubmaticBid objectForKey:kCreativeTagKey];
            
            if ([creativeObj isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary * creativeDict = creativeObj;
                PMNativeAdResponse * nativeAdResponse = [PMResponseParser parseDirectNativeAd:creativeDict];
                adResponse.rawResponse = creativeDict;
                adResponse.renderable = nativeAdResponse;
                
                
            }else{
                
                adResponse.error = [PMError errorWithCode:kPMErrorInvalidResponse description:@"Invalid native Ad"];
                
            }
            
        }
        
    }
    return adResponse;
}


@end
