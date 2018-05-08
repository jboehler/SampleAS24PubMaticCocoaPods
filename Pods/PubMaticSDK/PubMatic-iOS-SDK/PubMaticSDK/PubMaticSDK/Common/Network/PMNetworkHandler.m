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
#import "PMLogger.h"
#import "PMError.h"

static PMNetworkHandler *sharedInstance = nil;
static dispatch_once_t  oncePredecate;

@interface PMNetworkHandler()
@property (nonatomic) NSURLSession * session;
@end

@implementation PMNetworkHandler

+ (id)sharedNetworkHandler
{
    dispatch_once(&oncePredecate,^{
        sharedInstance = [[PMNetworkHandler alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype)init{
    
    self = [super init];
    if (self) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.URLCache = nil;
        config.timeoutIntervalForRequest = 10.0;
        config.URLCredentialStorage = nil;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.session = [NSURLSession sessionWithConfiguration:config];
        config = nil;
        
    }
    return self;
}

- (NSURLSessionTask * )performRequest:(NSURLRequest*)request success:(void (^)(NSData *data, NSURLResponse *response))successBlock failure:(void (^)(PMError *error))failureBlock
{
    return  [self performRequest:request success:successBlock failure:failureBlock redirection:nil];
}

- (NSURLSessionTask * )performRequest:(NSURLRequest*)request success:(void (^)(NSData *data, NSURLResponse *response))successBlock failure:(void (^)(PMError *error))failureBlock redirection:(NSURLRequest* (^)(NSURLRequest* request))redirectionBlock
{
    NSURLSessionDataTask * dt = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            ErrorLog(@"Error code: %ld Description: %@", error.code, error.localizedDescription);
            
            PMError *pmError = nil;
            NSString *errorMsg = error.localizedDescription;
            
            switch (error.code) {
                case NSURLErrorTimedOut:
                    pmError = [PMError errorWithCode:kPMErrorTimeout description:errorMsg];
                    break;
                    
                case NSURLErrorCancelled:
                    pmError = [PMError errorWithCode:kPMErrorRequestCancelled description:errorMsg];
                    break;
                    
                default:
                    pmError = [PMError errorWithCode:kPMErrorNetworkError description:errorMsg];
                    break;
            }
                        
            failureBlock(pmError);
            
        }else{
            successBlock(data,response);
        }
    }];
    
    [dt resume];
    return dt;
}

- (void)trackURL:(NSString *)urlString success:(void (^)(NSData *data, NSURLResponse *response))successBlock failure:(void (^)(PMError *error))failureBlock{
    
    NSURL *  url = [NSURL URLWithString:urlString];
    [self performRequest:[NSURLRequest requestWithURL:url] success:^(NSData *data, NSURLResponse *response) {
        successBlock(data,response);
    } failure:^(PMError *error) {
        failureBlock(error);
    }];
}
@end
