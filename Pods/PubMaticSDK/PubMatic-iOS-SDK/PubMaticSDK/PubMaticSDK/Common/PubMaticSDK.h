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

typedef NS_ENUM(NSInteger, PMLogLevel) {    
    
    /**
     *  No logs
     */
    PMLogLevelNone       = 0,
    
    /**
     *  Error logs only
     */
    PMLogLevelError,
    
    /**
     *  Error and warning logs
     */
    PMLogLevelWarn,
    
    /**
     *  Error, warning and info logs
     */
    PMLogLevelInfo,
    
    /**
     *  All logs, Error, warning, info and debug logs
     */
    PMLogLevelDebug
    
};

@interface PubMaticSDK : NSObject

/*!
 Sets log level across all formats, Default log level is PMLogLevelWarn
 */
+(void)setLogLevel:(PMLogLevel)logLevel;

/*! Returns the PubMatic SDK's version.
 */
+ (NSString*)sdkVersion;

/*! Used to enable or disable location detection.
 
 Enabling location detection makes use of the devices location services to
 set the lat and long server properties that will be sent with each ad request.
 
 Note that it could take time to acquire the location so an immediate update
 call after location detection enablement may not include the location in the
 ad network request.
 
 When enabling location detection with this method the most power efficient
 options are used based on the devices capabilities.
 
 @param enabled `YES` to enable location detection, `NO` to disable location detection.
 By default auto location detection is enabled
 */
+ (void)setLocationDetectionEnabled:(BOOL)enabled;

@end
