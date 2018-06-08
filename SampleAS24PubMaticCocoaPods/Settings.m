///*
// 
// * PubMatic Inc. ("PubMatic") CONFIDENTIAL
// 
// * Unpublished Copyright (c) 2006-2017 PubMatic, All Rights Reserved.
// 
// *
// 
// * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
// 
// * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
// 
// * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
// 
// * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
// 
// * Confidentiality and Non-disclosure agreements explicitly covering such access.
// 
// *
// 
// * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
// 
// * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
// 
// * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
// 
// * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
// 
// * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
// 
// */
//
//#import "Settings.h"
//#import "PubMaticSDK.h"
//
////PubMaticSDK extension to enable file logging, used for sample application only
//@interface PubMaticSDK ()
//+(void) enableFileLogging: (BOOL)fileLogging;
//@end
//
//@interface Settings ()
//@property (nonnull) NSMutableDictionary * config;
//@property (nonnull) NSDictionary * defaultConfig;
//@end
//
//@implementation Settings
//-(void)setAdRequest:(id)adRequest{
//    
//    _adRequest = adRequest;
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    _requestParamters = [_adRequest performSelector:@selector(paramsDictionary)];
//#pragma clang diagnostic pop
//}
//
//-(void)setAdResponse:(id)adResponse{
//    
//    _adResponse = adResponse;
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    id rawObj = [_adResponse performSelector:@selector(rawResponse)];
//#pragma clang diagnostic pop
//    if ([rawObj isKindOfClass:[NSData class]]) {
//        
//        NSData * data = rawObj;
//        _responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }else if ([rawObj isKindOfClass:[NSDictionary class]]) {
//        NSDictionary * data = rawObj;
//        
//        _responseString = [data description];
//    }
//}
//
//-(NSString *)defaultBannerWidth{
//    
//    if (!_defaultBannerWidth) {
//        _defaultBannerWidth = @"300";
//    }
//    return _defaultBannerWidth;
//}
//
//-(NSString *)bannerWidth{
//    
//    if (!_bannerWidth) {
//        _bannerWidth = [self defaultBannerWidth];
//    }
//    return _bannerWidth;
//}
//
//-(NSString *)bannerHeight{
//    
//    if (!_bannerHeight) {
//        _bannerHeight = @"250";
//    }
//    return _bannerHeight;
//}
//
//+ (Settings *)sharedInstance{
//    
//    static Settings *sharedInstance = nil;
//    static dispatch_once_t  oncePredecate;
//    
//    dispatch_once(&oncePredecate,^{
//        sharedInstance = [[Settings alloc] init];
//    });
//    return sharedInstance;
//}
//
//+(NSMutableDictionary *)defaultConfig{
//    
//    return [@{
//              @"0":[@{@"0":[@[@"156453",@"219778",@"1178234"] mutableCopy],
//                      @"1":[@[@"10002945"] mutableCopy]
//                      } mutableCopy],
//              @"1":[@{@"0":[@[@"156453",@"219778",@"1178356"] mutableCopy],
//                      @"1":[@[@"10002950"] mutableCopy]
//                      } mutableCopy],
//              @"2":[@{@"0":[@[@"156453",@"219778",@"1178273"] mutableCopy],
//                      @"1":[@[@"10002949"] mutableCopy]
//                      } mutableCopy]
//              } mutableCopy];
//}
//
//- (instancetype)init{
//    
//    self = [super init];
//    if (self) {
//        _useInternalBrowser = YES;
//        _autoLocationEnabled = YES;
//        _config = [Settings defaultConfig];
//        _customParameters = [NSMutableArray new];
//        _adWidth = 300;
//        _adHeight = 250;
//    }
//    return self;
//}
//
//-(void)addCutomParams:(NSDictionary *)customKeyValue{
//    
//    [_customParameters addObject:customKeyValue];
//}
//
//-(void)resetToDefault{
//    _config = [Settings defaultConfig];
//    _bannerWidth = _bannerHeight = nil;
//}
//
//-(void)resetLogs{
//    
//    [PubMaticSDK enableFileLogging:YES];
//}
//@end
