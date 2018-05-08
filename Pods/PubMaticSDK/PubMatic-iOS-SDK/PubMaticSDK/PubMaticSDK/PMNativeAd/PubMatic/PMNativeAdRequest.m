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

#define kAdTypeParam             @"adtype"
#define kAdTypeParamValue        @"12"

#import "PMNativeAdRequest.h"
#import "PMNativeAdRRFormatter.h"
#import "PMSDKUtil.h"
#import "FoundationCategories.h"
#import "PMLogger.h"
#import "PMBaseAdRequestPrivate.h"

@interface PMNativeAdRequest()

@end

@implementation PMNativeAdRequest
@synthesize adAssetArray = _adAssetArray;

- (NSMutableArray *)adAssetArray{
    
    if(!_adAssetArray){
        
        _adAssetArray = [[NSMutableArray alloc] init];
    }
    return _adAssetArray;
}

-(id)formatter{
    
    return [PMNativeAdRRFormatter new];
}

-(BOOL) addAsset:(PMNativeAssetRequest *) nativeAsset{
    
    if([nativeAsset isKindOfClass:([PMNativeAssetRequest class])])
    {
        
        [self.adAssetArray addObject:nativeAsset];
        return YES;
    }
    
    ErrorLog(@"Couldn't add nativeAsset Object , Object not of type PMNativeAsset");
    return NO;
}

-(NSDictionary *)paramsDictionary{
    
    NSMutableDictionary * params = [NSMutableDictionary new];
    NSDictionary * defaultParams = [super paramsDictionary];
    [params addEntriesFromDictionary:defaultParams];
    [params setObject:kAdTypeParamValue forKey:kAdTypeParam];
    return [NSDictionary dictionaryWithDictionary:params];
}

@end
