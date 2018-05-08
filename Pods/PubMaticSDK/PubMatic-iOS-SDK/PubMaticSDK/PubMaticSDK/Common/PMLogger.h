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
//  PMLogger.h

//


// SYSTEM IMPORTS
#import <Foundation/Foundation.h>
#import "PubMaticSDK.h"

#ifdef DEBUG

#define InfoLog(s,...)  [PMLogger logWithfunctionName:__PRETTY_FUNCTION__ lineNumber:__LINE__ withLogTag:PMLogLevelInfo  format:(s),##__VA_ARGS__]
#define DebugLog(s,...) [PMLogger logWithfunctionName:__PRETTY_FUNCTION__ lineNumber:__LINE__ withLogTag:PMLogLevelDebug format:(s),##__VA_ARGS__]
#define WarnLog(s,...)  [PMLogger logWithfunctionName:__PRETTY_FUNCTION__ lineNumber:__LINE__ withLogTag:PMLogLevelWarn  format:(s),##__VA_ARGS__]
#define ErrorLog(s,...) [PMLogger logWithfunctionName:__PRETTY_FUNCTION__ lineNumber:__LINE__ withLogTag:PMLogLevelError format:(s),##__VA_ARGS__]

#else

#define InfoLog(...) 
#define DebugLog(...) 
#define WarnLog(...)
#define ErrorLog(...) 

#endif


//
// This function changes the Log Level for SDK. By default Log Level is NONE i.e no messages will get logged from PubMatic Ad library.
// Logs can be enabled by changing this logLevel to any of the following values
//

@interface PMLogger : NSObject

// For Setting LogLevel
+(void) setLogLevel:(PMLogLevel) logLevel;

// For Getting LogLevel
+(PMLogLevel) getLogLevel;

+(void)logWithfunctionName:(const char*)functionName lineNumber:(int)lineNumber withLogTag:(PMLogLevel) logmode format:(NSString*)format, ...;

+(void) enableFileLogging: (BOOL)fileLogging;
@end
