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

#import "PMNetworkHandler.h"
#import "PMCommunicator.h"
#import "FoundationCategories.h"
#import "PMLogger.h"
#import "PMError.h"
#import "PMConstants.h"

#define ReachabilityTimeOut 5.f


@interface PMCommunicator ()
@property (nonatomic) NSMutableArray * array;
@end

@implementation PMCommunicator

+(void)checkUrl:(NSURL *)url Reachability:(CallBack)callback{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:ReachabilityTimeOut];
    [request setHTTPMethod:@"HEAD"];
    [[PMNetworkHandler sharedNetworkHandler] performRequest:request success:^(NSData *data, NSURLResponse *response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSHTTPURLResponse * aResponse = (NSHTTPURLResponse *) response;
            if(aResponse.statusCode!=200){
                
                callback(NO);
                
            }else{
                
                callback(YES);
            }
            
        });
    } failure:^(PMError *error) {
        callback(NO);
        ErrorLog(@"Error code: %ld Description: %@", error.code, [error description]);
    }];
}


-(void)dealloc{

    for (NSURLSessionTask * task  in _array) {
        [task cancel];
    }
    _array = nil;
}

+(instancetype)instance{
    
    return [[PMCommunicator alloc] init];
}

-(instancetype)init{
    
    self = [super init];
    if (self) {
        self.array = [NSMutableArray new];
    }
    return self;
}

-(void)fetchAd:(PMBaseAdRequest *)adRequest success:(SuccessBlock)successBlock failure:(ErrorBlock)errorBlock{
    
    NSURLRequest * urlRequest = [self.rrFormatter formatRequest:adRequest];
    __weak typeof(self) wSelf = self;

    if(urlRequest){
        NSURLSessionTask * task = [[PMNetworkHandler sharedNetworkHandler] performRequest:urlRequest success:^(NSData *data, NSURLResponse *response) {
            
            PMError *error = checkForOKResponse(response);
            
            if (error) {
                
                errorBlock(error);
                
                }else{

                PMAdResponse * adResponse = [wSelf.rrFormatter formatResponse:data];
                successBlock(adResponse);

            }
            
        } failure:^(PMError *error) {
            
            errorBlock(error);
            
        }];
        [_array addObject:task];
    }else{
        
        errorBlock([PMError errorWithCode:kPMErrorInternalError description:@"PubMatic SDK failed to format this request"]);
    }
}

- (void)trackURL:(NSString *)urlString success:(void (^)(NSData *data, NSURLResponse *response))successBlock failure:(void (^)(PMError *error))failureBlock{
    
    [[PMNetworkHandler sharedNetworkHandler] trackURL:urlString success:successBlock failure:failureBlock];
}

@end
