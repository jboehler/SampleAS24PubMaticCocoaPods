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

#import "PMResponseParser.h"
#import "PMNativeAdConstants.h"
#import "PMNativeAssetResponse.h"
#import "PMLogger.h"

@interface PMResponseParser()

+(PMNativeAdResponse *) parseDirectNativeAd:(NSDictionary*) responseDictionary;

@end

@implementation PMResponseParser

+(PMNativeAdResponse *) parseDirectNativeAd:(NSDictionary*) responseDictionary;
{
    
    PMNativeAdResponse *nativeResponse = [PMNativeAdResponse new];
    nativeResponse.landingPageURL = [NSURL URLWithString:[[[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseLinkKey] objectForKey:PMNativeAdResponseURLKey]];
    nativeResponse.creativeId = [responseDictionary valueForKey:PMNativeAdResponseAdCreativeIdKey];
    nativeResponse.impressionTrackerArray = [[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseImpressionTrackerKey];
    nativeResponse.jsTrackerString = [[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseJSTrackerKey];
    
    if ([[[[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseLinkKey] allKeys] containsObject:PMNativeAdResponseClickTrackerKey])
    {
        nativeResponse.clickTrackerArray = [[[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseLinkKey] objectForKey:PMNativeAdResponseClickTrackerKey];
    }
    
    NSArray *assetArray = [[responseDictionary objectForKey:@"native"] objectForKey:PMNativeAdResponseAssetKey];
    
    [[self class] parseAssetArray:assetArray toNativeResponse:nativeResponse];
    return nativeResponse;
}

+(PMNativeAdResponse*)parseIABNativeTemplate:(NSDictionary*)nativeDict
{
    PMNativeAdResponse *nativeResponse = [PMNativeAdResponse new];
    
    NSDictionary *link = [nativeDict objectForKey:PMNativeAdResponseLinkKey];
    //Landing page url
    nativeResponse.landingPageURL = [link isKindOfClass:[NSNull class]] ? nil : [link objectForKey:PMNativeAdResponseURLKey];
    
    //Impression trackers
    nativeResponse.impressionTrackerArray = [nativeDict objectForKey:PMNativeAdResponseImpressionTrackerKey];
    
    //js trackers
    nativeResponse.jsTrackerString = [nativeDict objectForKey:PMNativeAdResponseJSTrackerKey];
    
    //Click trackers
    if (![link isKindOfClass:[NSNull class]] && [link.allKeys containsObject:PMNativeAdResponseClickTrackerKey])
    {
        nativeResponse.clickTrackerArray = [[nativeDict objectForKey:PMNativeAdResponseLinkKey] objectForKey:PMNativeAdResponseClickTrackerKey];
    }
    
    //Native assets
    NSArray *assetArray = [nativeDict objectForKey:PMNativeAdResponseAssetKey];
    
    if (![assetArray isKindOfClass:[NSNull class]]) {
        
        [[self class] parseAssetArray:assetArray toNativeResponse:nativeResponse];
    }
    return nativeResponse;
}

+ (void)parseAssetArray:(NSArray *)assetArray toNativeResponse:(PMNativeAdResponse *)nativeResponse{
    
    for (NSDictionary *asset in assetArray) {
        
        NSInteger assetId = [[ asset objectForKey:@"id"] integerValue];
        if ([[asset allKeys] containsObject:@"img"]) {
            
            NSInteger width = [[[asset objectForKey:@"img"] objectForKey:@"w"] integerValue];
            NSInteger height = [[[asset objectForKey:@"img"] objectForKey:@"h"] integerValue];
            
            PMNativeImageAssetResponse * imageAsset = [[PMNativeImageAssetResponse alloc] initWithId:assetId withWidth:width withHeight:height andImageURL:[[asset objectForKey:@"img"] objectForKey:@"url"]];
            [nativeResponse.adAssetResponseArray addObject:imageAsset];
            
        } else if ([[asset allKeys] containsObject:@"data"]){
            
            PMNativeDataAssetResponse * dataAsset = [[PMNativeDataAssetResponse alloc]
                                                     initWithId:assetId withValue:[[asset objectForKey:@"data"] objectForKey:@"value"]];
            [nativeResponse.adAssetResponseArray addObject:dataAsset];
            
        } else if ([[asset allKeys] containsObject:@"title"]){
            PMNativeTitleAssetResponse *titleAsset = [[PMNativeTitleAssetResponse alloc] initWithId:assetId withValue:[[asset objectForKey:@"title"] objectForKey:@"text"]];
            [nativeResponse.adAssetResponseArray addObject:titleAsset];
        }
    }
}
@end
