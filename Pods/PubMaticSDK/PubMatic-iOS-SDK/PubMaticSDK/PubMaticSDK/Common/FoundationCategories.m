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


#import "FoundationCategories.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "PMLogger.h"

@implementation NSString (Addition)

- (NSString *) urlDecode{
    
    return  [self stringByRemovingPercentEncoding];
}

static NSMutableCharacterSet * charSet = nil;

- (NSString *)urlencode {
    
    if (!charSet) {
        charSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [charSet removeCharactersInString:@"!*'();:@&=+$,/?%#[]<>"];
    }
    return [self stringByAddingPercentEncodingWithAllowedCharacters:charSet];
}

#pragma mark - Helpers for Hashing
- (NSString*)hashUsingSHA1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (uint)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [NSString stringWithString:output];
}

- (NSString *)hashUsingMD5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (uint)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  [NSString stringWithString:output];
}

@end



@implementation NSDictionary (QueryString)
-(NSString *)queryString{
    
    __block NSString * queryString = @"";
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull akey, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString * key = akey;
        NSSet * valueObject = obj;
        
        if([valueObject isKindOfClass:[NSString class]]){
            
            queryString = [queryString stringByAppendingFormat:@"%@=%@&",key,(NSString *)obj];
            
            
        } else if([valueObject isKindOfClass:[NSSet class]]){
            
            NSSet * values = valueObject;
            for (NSString * value in values) {
                
                if([value isKindOfClass:[NSString class]]){
                    
                    queryString = [queryString stringByAppendingFormat:@"%@=%@&",key,value];
                    
                }else{
                    
                    DebugLog(@"Found non-string value while creating query string");
                    
                }
            }
            
        }else{
            
            DebugLog(@"Found non-string value while creating query string");
        }
        
    }];
    
    if([queryString length]){
        
        queryString = [queryString stringByReplacingCharactersInRange:NSMakeRange([queryString length]-1, 1) withString:@""];
    }
    return queryString;
}

-(NSString *)queryStringWithEncoding{
    
    __block NSString * queryString = @"";
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull akey, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString * key = akey;
        NSSet * valueObject = obj;
        
        if([valueObject isKindOfClass:[NSString class]]){
            
            queryString = [queryString stringByAppendingFormat:@"%@=%@&",key,[(NSString *)obj urlencode]];
            
            
        } else if([valueObject isKindOfClass:[NSSet class]]){
            
            NSSet * values = valueObject;
            for (NSString * value in values) {
                
                if([value isKindOfClass:[NSString class]]){
                    
                    queryString = [queryString stringByAppendingFormat:@"%@=%@&",key,value.urlencode];
                    
                }else{
                    
                    DebugLog(@"Found non-string value while creating query string");
                    
                }
            }
            
        }else{
            
            DebugLog(@"Found non-string value while creating query string");
        }
        
        
    }];
    
    if([queryString length]){
        
        queryString = [queryString stringByReplacingCharactersInRange:NSMakeRange([queryString length]-1, 1) withString:@""];
    }
    return queryString;
}
@end


@implementation NSMutableDictionary (SafeMutableDictionary)
-(void)setObjectSafely:(id)anObject forKey:(id<NSCopying>)aKey{
    
    if(anObject){
        
        if(!(([anObject isKindOfClass:[NSArray class]] && [anObject count]==0) || ([anObject isKindOfClass:[NSString class]] && [(NSString*)anObject length]==0))){
            
            [self setObject:anObject forKey:aKey];
        }
    }
}

-(void)replaceKey:(NSString *)oldKey withKey:(NSString *)newKey{
    
    id objectForOldKey = [self objectForKey:oldKey];
    [self setObjectSafely:objectForOldKey forKey:newKey];
    [self removeObjectForKey:oldKey];
    
}

-(id)popObjetForKey:(NSString *)key{
    
    id obj = [self objectForKey:key];
    [self removeObjectForKey:key];
    return obj;
}
@end
