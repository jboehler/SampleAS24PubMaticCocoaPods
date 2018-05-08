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
//  PMNativeAsset.m
//   PMBannerAdView 
//

#import "PMNativeAssetRequest.h"

@interface PMNativeAssetRequest(){
    
@protected
    NSMutableDictionary * _entityDictionary;
}
@end

@implementation PMNativeAssetRequest
@synthesize entityDictionary = _entityDictionary;

- (instancetype)initWithAssetId:(NSInteger)assetId type:(NSString *)type
{
    self = [super init];
    if (self) {
        _assetId=assetId;
        _type = type;
        _entityDictionary = [NSMutableDictionary new];
    }
    return self;
}

-(NSMutableDictionary *) getJSONDictionary
{
    NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
    [finalDictionary setObject:[NSNumber numberWithInteger:self.assetId] forKey:@"id"];
    [finalDictionary setObject:[NSNumber numberWithInteger:self.required] forKey:@"required"];
    [finalDictionary setObject:self.entityDictionary forKey:self.type];
    return finalDictionary;
    
}

@end


@implementation PMNativeDataAssetRequest

-(instancetype)initWithId:(NSInteger)assetId
                  subtype:(PMNativeDataAssetType)subtype{
    
    self = [super initWithAssetId:assetId type:@"data"];
    if (self) {
        
        _subtype=subtype;
        [_entityDictionary setObject:[NSNumber numberWithInteger:subtype] forKey:@"type"];        
    }
    return self;
}

-(instancetype)initWithId:(NSInteger)assetId
                     subtype:(PMNativeDataAssetType)subtype
                   length:(NSInteger)length{
    
    self = [super initWithAssetId:assetId type:@"data"];
    if (self) {
        
        _subtype=subtype;
        _length=length;
        [_entityDictionary setObject:[NSNumber numberWithInteger:length] forKey:@"len"];
        [_entityDictionary setObject:[NSNumber numberWithInteger:subtype] forKey:@"type"];

    }
    return self;
}

@end


@implementation PMNativeImageAssetRequest

-(instancetype)initWithId:(NSInteger)assetId
                     subtype:(PMNativeImageAssetType)subtype
                    width:(NSInteger)width
                   height:(NSInteger)height{
    
    self = [super initWithAssetId:assetId type:@"img"];
    if (self) {
        
        _width=width;
        _subtype=subtype;
        [_entityDictionary setObject:[NSNumber numberWithInteger:subtype] forKey:@"type"];
        [_entityDictionary setObject:[NSNumber numberWithInteger:width] forKey:@"w"];
        _height=height;
        [_entityDictionary setObject:[NSNumber numberWithInteger:height] forKey:@"h"];
    }
    return self;
}

-(void)setMimeTypes:(NSArray *)mimeTypes
{
    if ([mimeTypes isKindOfClass:[NSArray class]] && mimeTypes.count > 0) {
        _mimeTypes = mimeTypes;
        [_entityDictionary setObject:mimeTypes forKey:@"mimes"];
    }
}
@end

@interface PMNativeTitleAssetRequest ()
@property(nonatomic,assign,readonly) NSInteger titleLength;
@end

@implementation PMNativeTitleAssetRequest

-(instancetype)initWithId:(NSInteger)assetId length:(NSInteger)lenght{
    
    self = [super initWithAssetId:assetId type:@"title"];
    if (self) {
        _titleLength = lenght;
        [_entityDictionary setObject:[NSNumber numberWithInteger:self.titleLength] forKey:@"len"];
    }
    return self;
}
@end
