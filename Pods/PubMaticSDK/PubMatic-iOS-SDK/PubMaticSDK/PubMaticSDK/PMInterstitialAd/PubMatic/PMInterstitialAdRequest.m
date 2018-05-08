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


#import "PMInterstitialAdRequest.h"
#import "PMAdRequest.h"
#import "PMSDKUtil.h"
#import "PMBaseAdRequestPrivate.h"
#import "PMBannerRRFormatter.h"
#import "PMLogger.h"
#import "FoundationCategories.h"
#import "PMConstants.h"

@interface PMInterstitialAdRequest ()
/*!
 Indicates whether the tracking URL has been wrapped or not in the creative tag.
 */
@property (nonatomic, assign) PMAWT awt;

@end

@implementation PMInterstitialAdRequest


- (id)initWithPublisherId:(NSString *)pubId siteId:(NSString *)siteId
                     adId:(NSString *)adId{
    
    self = [super initWithPublisherId:pubId siteId:siteId adId:adId];
    if(self){
        
    }
    return self;
}

-(id)formatter{
    
    return [PMBannerRRFormatter new];
}

-(PMError *)validate{
    
    return [super validate];;
}

-(NSDictionary *)paramsDictionary{
    
    NSMutableDictionary * params = [NSMutableDictionary new];
    NSDictionary * defaultParams = [super paramsDictionary];
    [params addEntriesFromDictionary:defaultParams];
    
    // Setting adOrientation
    if(self.adOrientation == PMADOrientationPortrait || self.adOrientation == PMADOrientationLandscape){
        [params setObject:[NSString stringWithFormat:@"%d",(int)self.adOrientation] forKey:kAdOrientationParam];
    }
    [params setObject:@"1" forKey:kInterstitialParam];
    [params setObject:kInterstitialAdTypeParamValue forKey:kAdTypeParam];
    [params setObjectSafely:[NSString stringWithFormat:@"%ld",(long)self.awt] forKey:kAwt];

    NSMutableString * admultisizeValue = [NSMutableString new];
    NSUInteger count = self.optionalAdSizes.count;
    [self.optionalAdSizes enumerateObjectsUsingBlock:^(NSValue * value, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize size = [value CGSizeValue];
        
        [admultisizeValue appendFormat:@"%dx%d",(int)size.width,(int)size.height];
        if (idx < (count-1)) {
            [admultisizeValue appendString:@","];
        }
    }];
    
    if (admultisizeValue.length) {
        
        [params setObjectSafely:admultisizeValue forKey:@"multisize"];
    }
    
    return [NSDictionary dictionaryWithDictionary:params];
}@end
