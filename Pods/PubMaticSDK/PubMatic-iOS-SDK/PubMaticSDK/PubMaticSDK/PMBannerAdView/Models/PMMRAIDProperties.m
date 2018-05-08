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
//   PMBannerAdView 
//
//  Created on 9/21/12.

//

#import "PMMRAIDProperties.h"

static NSString* PMMRAIDExpandPropertiesWidth = @"width";
static NSString* PMMRAIDExpandPropertiesHeight = @"height";
static NSString* PMMRAIDExpandPropertiesUseCustomClose = @"useCustomClose";

@implementation PMMRAIDExpandProperties

@synthesize width, height, useCustomClose;


+ (PMMRAIDExpandProperties*)propertiesFromArgs:(NSDictionary*)args
{
    PMMRAIDExpandProperties* properties = [PMMRAIDExpandProperties new];
    properties.width = [[args valueForKey:PMMRAIDExpandPropertiesWidth] integerValue];
    properties.height = [[args valueForKey:PMMRAIDExpandPropertiesHeight] integerValue];
    properties.useCustomClose = [[args valueForKey:PMMRAIDExpandPropertiesUseCustomClose] isEqualToString:@"true"];
    return properties;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.width = 0;
        self.height = 0;
        self.useCustomClose = false;
    }
    return self;
}

- (id)initWithSize:(CGSize)size
{
    self = [self init];
    if (self)
    {
        self.width = size.width;
        self.height = size.height;
    }
    return self;
}

- (NSString*)description
{
    NSString* ucc = @"false";
    if (self.useCustomClose)
        ucc = @"true";
    
    NSString* desc = [NSString stringWithFormat:@"{width:%d,height:%d,useCustomClose:%@}",
                      (int)self.width, (int)self.height, ucc];
    
    return desc;
}

@end


static NSString* PMMRAIDOrientationPropertiesAllowOrientationChange = @"allowOrientationChange";
static NSString* PMMRAIDOrientationPropertiesFOrientation = @"forceOrientation";

static NSString* PMMRAIDOrientationPropertiesFOrientationPortrait = @"portrait";
static NSString* PMMRAIDOrientationPropertiesFOrientationLandscape = @"landscape";
static NSString* PMMRAIDOrientationPropertiesFOrientationNone = @"none";


@implementation PMMRAIDOrientationProperties

@synthesize allowOrientationChange, forceOrientation;


+ (PMMRAIDOrientationProperties*)propertiesFromArgs:(NSDictionary*)args
{
    PMMRAIDOrientationProperties* properties = [PMMRAIDOrientationProperties new];
    
    //As per mraid 2.0 default value allowOrientationChange
    properties.allowOrientationChange = ![[args valueForKey:PMMRAIDOrientationPropertiesAllowOrientationChange] isEqualToString:@"false"];
    
    properties.forceOrientation = PMMRAIDOrientationPropertiesForceOrientationNone;
    NSString* fo = [args valueForKey:PMMRAIDOrientationPropertiesFOrientation];
    if ([fo isEqualToString:PMMRAIDOrientationPropertiesFOrientationPortrait])
    {
        properties.forceOrientation = PMMRAIDOrientationPropertiesForceOrientationPortrait;
    }
    else if ([fo isEqualToString:PMMRAIDOrientationPropertiesFOrientationLandscape])
    {
        properties.forceOrientation = PMMRAIDOrientationPropertiesForceOrientationLandscape;
    }
    
    return properties;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.allowOrientationChange = true;
        self.forceOrientation = PMMRAIDOrientationPropertiesForceOrientationNone;
    }
    return self;
}

- (NSString*)description
{
    NSString* aoc = @"false";
    if (self.allowOrientationChange)
        aoc = @"true";
    
    NSString* fo = nil;
    switch (self.forceOrientation)
    {
        case PMMRAIDOrientationPropertiesForceOrientationPortrait:
            fo = PMMRAIDOrientationPropertiesFOrientationPortrait;
            break;
            
        case PMMRAIDOrientationPropertiesForceOrientationLandscape:
            fo = PMMRAIDOrientationPropertiesFOrientationLandscape;
            break;
            
        default:
            fo = PMMRAIDOrientationPropertiesFOrientationNone;
            break;
    }
    
    NSString* desc = [NSString stringWithFormat:@"{allowOrientationChange:%@,forceOrientation:'%@'}", aoc, fo];
    
    return desc;
}

@end


static NSString* PMMRAIDResizePropertiesWidth = @"width";
static NSString* PMMRAIDResizePropertiesHeight = @"height";
static NSString* PMMRAIDResizePropertiesCustomClosePosition = @"customClosePosition";
static NSString* PMMRAIDResizePropertiesOffsetX = @"offsetX";
static NSString* PMMRAIDResizePropertiesOffsetY = @"offsetY";
static NSString* PMMRAIDResizePropertiesAllowOffscreen = @"allowOffscreen";

static NSString* PMMRAIDResizePropertiesCCPositionTopLeft = @"top-left";
static NSString* PMMRAIDResizePropertiesCCPositionTopCenter = @"top-center";
static NSString* PMMRAIDResizePropertiesCCPositionTopRight = @"top-right";
static NSString* PMMRAIDResizePropertiesCCPositionCenter = @"center";
static NSString* PMMRAIDResizePropertiesCCPositionBottomLeft = @"bottom-left";
static NSString* PMMRAIDResizePropertiesCCPositionBottomCenter = @"bottom-center";
static NSString* PMMRAIDResizePropertiesCCPositionBottomRight = @"bottom-right";


@implementation PMMRAIDResizeProperties

@synthesize width, height, customClosePosition, offsetX, offsetY, allowOffscreen;


+ (PMMRAIDResizeProperties*)propertiesFromArgs:(NSDictionary*)args
{
    PMMRAIDResizeProperties* properties = [PMMRAIDResizeProperties new];
    properties.width = [[args valueForKey:PMMRAIDResizePropertiesWidth] integerValue];
    properties.height = [[args valueForKey:PMMRAIDResizePropertiesHeight] integerValue];
    properties.offsetX = [[args valueForKey:PMMRAIDResizePropertiesOffsetX] integerValue];
    properties.offsetY = [[args valueForKey:PMMRAIDResizePropertiesOffsetY] integerValue];
    properties.allowOffscreen = ![[args valueForKey:PMMRAIDResizePropertiesAllowOffscreen] isEqualToString:@"false"];
    
    NSString* ccp = [args valueForKey:PMMRAIDResizePropertiesCustomClosePosition];
    if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionTopLeft])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionTopLeft;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionTopCenter])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionTopCenter;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionTopRight])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionTopRight;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionCenter])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionCenter;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionBottomLeft])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionBottomLeft;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionBottomCenter])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionBottomCenter;
    }
    else if ([ccp isEqualToString:PMMRAIDResizePropertiesCCPositionBottomRight])
    {
        properties.customClosePosition = PMMRAIDResizeCustomClosePositionBottomRight;
    }
    
    return properties;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Defaults
        self.customClosePosition = PMMRAIDResizeCustomClosePositionTopRight;
    }
    return self;
}

- (NSString*)description
{
    NSString* ccp = nil;
    switch (self.customClosePosition)
    {
        case PMMRAIDResizeCustomClosePositionTopLeft:
            ccp = PMMRAIDResizePropertiesCCPositionTopLeft;
            break;
        case PMMRAIDResizeCustomClosePositionTopCenter:
            ccp = PMMRAIDResizePropertiesCCPositionTopCenter;
            break;
        case PMMRAIDResizeCustomClosePositionTopRight:
            ccp = PMMRAIDResizePropertiesCCPositionTopRight;
            break;
        case PMMRAIDResizeCustomClosePositionCenter:
            ccp = PMMRAIDResizePropertiesCCPositionCenter;
            break;
        case PMMRAIDResizeCustomClosePositionBottomLeft:
            ccp = PMMRAIDResizePropertiesCCPositionBottomLeft;
            break;
        case PMMRAIDResizeCustomClosePositionBottomCenter:
            ccp = PMMRAIDResizePropertiesCCPositionBottomCenter;
            break;
        case PMMRAIDResizeCustomClosePositionBottomRight:
            ccp = PMMRAIDResizePropertiesCCPositionBottomRight;
            break;
    }
    
    NSString* ao = @"false";
    if (self.allowOffscreen)
        ao = @"true";
    
    NSString* desc = [NSString stringWithFormat:@"{width:%d,height:%d,customClosePosition:'%@',offsetX:%d,offsetY:%d,allowOffscreen:%@}", (int)self.width, (int)self.height, ccp, (int)self.offsetX, (int)self.offsetY, ao];
    
    return desc;
}

@end
