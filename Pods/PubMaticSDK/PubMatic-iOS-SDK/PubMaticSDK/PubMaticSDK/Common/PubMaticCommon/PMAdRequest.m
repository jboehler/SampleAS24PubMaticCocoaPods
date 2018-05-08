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

#import "PMAdRequest.h"
#import "FoundationCategories.h"
#import "PMSDKUtil.h"
#import "PMBaseAdRequestPrivate.h"
#import "PMConstants.h"
#import "FoundationCategories.h"
#import "PMError.h"

@interface PMAdRequest()
@property (nonatomic, strong) NSString * siteId;
@property (nonatomic, strong) NSString * adTagId;
@property (nonatomic) NSURL * hostURL;

@end

@implementation PMAdRequest

@synthesize custParamdict = _custParamdict;

+(NSString *)secureBaseURLString{
    
    return PM_SECURE_SERVER_URL;
}

+(NSString *)baseURLString{
    
    return PM_SERVER_URL;
}

-(NSString *)adServerURL{
    
    if (self.requestSecureCreative) {
        return [[self class] secureBaseURLString];
    }else{
        return [[self class] baseURLString];
    }
}

- (id)initWithPublisherId:(NSString *)pubId siteId:(NSString *)siteId
                     adId:(NSString *)adId{
    
    self = [super init];
    if(self){
        _publisherId = pubId;
        _siteId = siteId;
        _adTagId = adId;
        _isIDFAEnabled = YES;
        _udidHashType = PMUdidhashTypeRaw;
        _ethnicity = -1;
        _locationSource = PMLocSourceUnknown;
        _gender = -1;
        _applicationPaid = -1;
        _coppa = -1;
    }
    return self;
}

-(NSDictionary *)custParamdict{
    
    if(!_custParamdict){
        _custParamdict = [NSDictionary new];
    }
    return _custParamdict;
    
}

-(PMError *)validate{
    
    PMError * error = [super validate];
    
    if(!(self.publisherId.length && self.siteId.length && self.adTagId.length)){
        
        return [PMError errorWithCode:kPMErrorInvalidRequest description:@"Missing mandatory parameter"];
    }
    
    return error;
}

-(NSURL *)hostURL{
    
    if (!_hostURL) {
        
        NSURL * adserverURL = [NSURL URLWithString:self.adServerURL];
        NSString * baseURLString = [NSString stringWithFormat:@"%@://%@",adserverURL.scheme,adserverURL.host];
        _hostURL = [NSURL URLWithString:baseURLString];
    }
    return _hostURL;
}
/*!Saves custom parameters in form of
 key => value or key => Set<value1,value2....valuen>
 if multiple values are set against same key it will save those values as NSSet of values against given key in NSDictionary
 e.g. key => Set<value1,value2....valuen>
 */
-(void)setCustomParam:(NSString *)paramValue forKey:(NSString *)paramKey{
    
    if (![paramValue length] || ![paramKey length]) {
        return;
    }
    
    NSMutableDictionary * mDict = [[self custParamdict] mutableCopy];
    if([mDict objectForKey:paramKey]){
        
        NSSet * set = [mDict objectForKey:paramKey];
        NSMutableSet * mSet = [set mutableCopy];
        [mSet addObject:paramValue];
        [mDict setObject:[NSSet setWithSet:mSet]forKey:paramKey];
        
    }else{
        
        NSSet * set = [NSSet setWithObject:paramValue];
        [mDict setObject:[NSSet setWithSet:set]forKey:paramKey];
    }
    _custParamdict = [NSDictionary dictionaryWithDictionary:mDict];
    
}

-(NSDictionary *)defaultParams{
    
    PMSDKUtil *util = [PMSDKUtil sharedInstance];
    
    NSMutableDictionary * params = [NSMutableDictionary new];
    
    if (self.requestSecureCreative) {
        [params setObject:@"1" forKey:@"sec"];
    }
    [params setObjectSafely:self.pmZoneId forKey:kPMZoneIDParam];
    [params setObjectSafely:[NSString stringWithFormat:@"%f",util.currentTimeZone] forKey:kTimezoneParam];
    [params setObjectSafely:util.deviceScreenResolution  forKey:kScreenResolutionParam];
    [params setObjectSafely:[ util appBundleIdentifier ] forKey:kBundleParam];
    [params setObjectSafely:self.storeURL forKey:kAppStoreUrl];
    
    [params setObjectSafely:[NSString stringWithFormat:@"%ld", (long)self.udidHashType] forKey:kUdidHashParam];
    
    [params setObjectSafely:util.deviceMake forKey:kMakeParam];
    [params setObjectSafely:util.deviceModel forKey:kModelParam];
    [params setObjectSafely:util.deviceOSName forKey:kOsParam];
    [params setObjectSafely:util.deviceOSversion forKey:kOsvParam];
    NSString * carrier = util.carrierName;
    [params setObjectSafely:carrier forKey:kCarrierParam];
    [params setObjectSafely:[util deviceAcceptLanguage ] forKey:kLanguage];
    
    
    [params setObjectSafely:[util countryCode ]  forKey:kCountryParam];
    
    [params setObjectSafely:[util applicationName ] forKey:kAppName];
    
    [params setObjectSafely:[util appVersion ]  forKey:kVerParam];
    
    [params setObjectSafely:util.sdkVersion forKey:kSDK_VerParam];
    
    [params setObjectSafely:kAPIParamValue  forKey:kAPIParam];
    
    [params setObjectSafely:util.pageURL forKey:kPageURLParam];
    return [NSDictionary dictionaryWithDictionary:params];
}

-(NSDictionary *)paramsDictionary{
    
    NSMutableDictionary * params = [NSMutableDictionary new];
    NSDictionary * defaultParams = [self defaultParams];
    [params addEntriesFromDictionary:defaultParams];
    
    [params setObject:[NSString stringWithFormat:@"%d",(int)kOperIdValue] forKey:kOperIdParam];
    [params setObjectSafely:self.publisherId forKey:kPubIdParam];
    [params setObjectSafely:self.siteId forKey:kSiteIdParam];
    [params setObjectSafely:self.adTagId forKey:kAdIdParam];
    [params setObject:kAdPositionParamDefaultValue forKey:kAdPositionParam];

    [params setObjectSafely:[self birthYear] forKey:kYobParam];
    [params setObjectSafely:[PMSDKUtil stringFromGender:self.gender] forKey:kGenderParam];
    
    [params setObjectSafely:self.zip forKey:kZipParam];
    [params setObjectSafely:self.state forKey:kStateParam];
    [params setObjectSafely:self.city forKey:kCityParam];
    [params setObjectSafely:self.keywords forKey:kKeywordsParam];
    
    [params setObjectSafely:self.dma forKey:kDMAParam];
    
    [params setObjectSafely:[self userIncome] forKey:kUserIncome];
    if (self.ethnicity >= 0) {
        [params setObjectSafely:[NSString stringWithFormat:@"%ld",(long)self.ethnicity] forKey:kUserEthnicity];
    }
    
    [params setObjectSafely:self.appDomain forKey:kAppDomain];
    
    if (self.coppa == PMBOOLYes) {
        [params setObject:@"1" forKey:kCoppaParam];
    }
    else if (self.coppa == PMBOOLNo){
        [params setObject:@"0" forKey:kCoppaParam];
    }
    
    if (self.applicationPaid == PMBOOLYes) {
        [params setObject:@"1" forKey:kAppPaid];
    }
    else if (self.applicationPaid == PMBOOLNo){
        [params setObject:@"0" forKey:kAppPaid];
    }
    
    [params setObject:@"1" forKey:kJsParam];
    
    [params setObjectSafely:self.appCategory forKey:kAppCat];
    [params setObjectSafely:self.aid forKey:kAppID];
    [params setObject:kInIframeParamValue forKey:kInIframeParam];
    [params setObjectSafely:[[PMSDKUtil sharedInstance] sdkId] forKey:kSDK_IdParam];
    [params setObjectSafely:[self dctr] forKey:kDCTR_Param];
    return [NSDictionary dictionaryWithDictionary:params];
    
}

/*
 Allows key-value pair information to be passed to the SSP platform.
 
 Multiple values and syntax are allowed as follows: dctr=ENCODED<key1=V1,V2,V3|key2=v1|key3=v3,v5>
 
 Example:
 
 dctr=company%3Dpubmatic%7Cplace%3Dpune%2Cbanglore
 
 */
-(NSString *)dctr{
    
    __block NSMutableString * dctrValue = [NSMutableString new];
    [self.custParamdict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            [dctrValue appendFormat:@"%@=%@",key,[obj string]];
            
        }else if([obj isKindOfClass:[NSSet class]]){
            
            NSArray * array = [(NSSet*)obj allObjects];
            [dctrValue appendFormat:@"%@=%@",key,[array componentsJoinedByString:@","]];
        }
        [dctrValue appendString:@"|"];
    }];
    if (dctrValue.length) {
        [dctrValue deleteCharactersInRange:NSMakeRange(dctrValue.length-1, 1)];
    }
    return dctrValue;
}
@end
