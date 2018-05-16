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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Settings : NSObject
@property (nonatomic) id adRequest;
@property (nonatomic) id adResponse;

@property (nonatomic) NSDictionary * requestParamters;
@property (nonatomic) NSString * responseString;

@property (nonatomic,assign) BOOL useInternalBrowser;
@property (nonatomic,assign) BOOL autoLocationEnabled;
@property (nonatomic,assign) BOOL doNotTrack;

@property (nonatomic,strong) NSString * bannerWidth;
@property (nonatomic,strong) NSString * defaultBannerWidth;
@property (nonatomic,strong) NSString * bannerHeight;

@property (nonatomic,strong) NSString * contry;
@property (nonatomic,strong) NSString * city;
@property (nonatomic,strong) NSString * zipCode;

@property (nonatomic,assign) CGFloat adWidth;
@property (nonatomic,assign) CGFloat adHeight;


@property (readonly, nonatomic) NSMutableArray * customParameters;

-(void)addCutomParams:(NSDictionary *)customKeyValue;

+ (Settings *)sharedInstance;

-(void)resetToDefault;
-(NSString *)input1ForAdType:(NSInteger)adType andPlatforms:(NSInteger)adType;
-(NSString *)input2ForAdType:(NSInteger)adType andPlatforms:(NSInteger)adType;
-(NSString *)input3ForAdType:(NSInteger)adType andPlatforms:(NSInteger)adType;

-(void )setInput1:(NSString *)value forAdType:(NSInteger)adType andPlatforms:(NSInteger)platform;
-(void)setInput2:(NSString *)value forAdType:(NSInteger)adType andPlatforms:(NSInteger)platform;
-(void)setInput3:(NSString *)value forAdType:(NSInteger)adType andPlatforms:(NSInteger)platform;

-(void)resetLogs;
@end
