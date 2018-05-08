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
//  PMLoggers.m

//


//SYSTEM INCLUDES
#import "TargetConditionals.h"

//USER INCLUDES
#import "PMLogger.h"

static PMLogLevel _logLevel = PMLogLevelWarn;
static BOOL enableFileLog = NO;

@implementation PMLogger

#pragma mark -  Public Functions

+(void) enableFileLogging: (BOOL)fileLogging{
    if (fileLogging) {
        [PMLogger deleteLogFile];
    }
    enableFileLog = fileLogging;
}

+(BOOL) fileLogging{
    return enableFileLog;
}

+(void) setLogLevel:(PMLogLevel) logLevel{
    _logLevel = logLevel;
}

+(PMLogLevel) getLogLevel{
    return _logLevel;
}

+(NSString *) getLogModeStringWithLogTag:(PMLogLevel) level{
    switch(level)
    {
        case PMLogLevelInfo: return @"INFO";
            break;
            
        case PMLogLevelDebug: return @"DEBUG";
            break;
            
        case PMLogLevelWarn: return @"WARNING";
            break;
            
        case PMLogLevelError: return @"ERROR";
            break;
        case PMLogLevelNone: return @"NONE";
            break;
            
    }
    return nil;
}

#pragma mark -  Private Functions

+(void)logWithfunctionName:(const char*)functionName
                lineNumber:(int)lineNumber withLogTag:(PMLogLevel)level
                    format:(NSString*)format, ...{
    if(_logLevel >= level && format!=nil)
    {
        va_list ap;
        NSString *msg,*fName;
        va_start(ap,format);
        msg=[[NSString alloc] initWithFormat:format arguments:ap];
        fName = [NSString stringWithUTF8String:functionName];
        va_end(ap);
        NSString *message = [NSString stringWithFormat:@"%s [Line %d]: %@",[[fName lastPathComponent] UTF8String],lineNumber,msg];
        NSString *logMessage = [PMLogger createLogMessageUsingMessage: message  withLogTag:level];
        NSLog(@"%@",logMessage);
        
        if ([self fileLogging]) {
            [PMLogger logToFile: logMessage];
        }
    }
}

static NSString * logFilePath = nil;

+(NSString *)filePath{
    
    if (!logFilePath) {
        
        NSString *fileName = @"pubmatic_sdk_logs";
        // Point to Document directory
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [documentsDirectory
                              stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            logFilePath = filePath;
        }
    }
    return logFilePath;
}

static NSFileHandle *handle = nil;

+(NSFileHandle *)LogFileHandle{
    
    if (!handle) {
        handle = [NSFileHandle fileHandleForWritingAtPath:[PMLogger filePath]];
    }
    return handle;
}

+(void) logToFile:(NSString *) message{
    
    handle = [PMLogger LogFileHandle];
    NSString * msg = [NSString stringWithFormat:@"\n%@ #%@",[PMLogger currentTimeStamp],message];
    [handle seekToEndOfFile];
    [handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
}

static NSDateFormatter * dateFormatter = nil;

+(NSString*) currentTimeStamp{
    
    if (!dateFormatter) {
        
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.sss"];
    }
    return [dateFormatter stringFromDate:[NSDate date]];
}

+(NSString *) createLogMessageUsingMessage:(NSString *) message
                                withLogTag:(PMLogLevel) logtag{
    
    NSString * logMsg = [NSString stringWithFormat:@"\n%@ : %@ ",[PMLogger getLogModeStringWithLogTag:logtag],message];
    return logMsg;
}

+(void) deleteLogFile{
    // Create file manager
    NSString *filePath = [PMLogger filePath];
    NSError * error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (!error) {
        logFilePath = nil;
        [handle closeFile];
        handle = nil;
    }
}
@end
