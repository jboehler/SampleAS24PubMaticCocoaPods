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

#import "PMMRAIDBridge.h"

static NSString* MRAIDBridgeTrue = @"true";
static NSString* MRAIDBridgeFalse = @"false";

static NSString* MRAIDBridgePTypeInline = @"inline";
static NSString* MRAIDBridgePTypeInterstitial = @"interstitial";

static NSString* MRAIDBridgeArgURL = @"url";
static NSString* MRAIDBridgeArgEvent = @"event";

static NSString* MRAIDBridgeSLoading = @"loading";
static NSString* MRAIDBridgeSDefault = @"default";
static NSString* MRAIDBridgeSExpanded = @"expanded";
static NSString* MRAIDBridgeSResized = @"resized";
static NSString* MRAIDBridgeSHidden = @"resized";

static NSString* MRAIDBridgeFeatureSMS = @"sms";
static NSString* MRAIDBridgeFeatureTel = @"tel";
static NSString* MRAIDBridgeFeatureCalendar = @"calendar";
static NSString* MRAIDBridgeFeatureStorePicture = @"storePicture";
static NSString* MRAIDBridgeFeatureInlineVideo = @"inlineVideo";

static NSString* MRAIDBridgeEReady = @"ready";

static NSString* MRAIDBridgeCommandInit = @"init";
static NSString* MRAIDBridgeCommandClose = @"close";
static NSString* MRAIDBridgeCommandOpen = @"open";
static NSString* MRAIDBridgeCommandUpdateCurrentPosition = @"updateCurrentPosition";
static NSString* MRAIDBridgeCommandExpand = @"expand";
static NSString* MRAIDBridgeCommandResize = @"resize";
static NSString* MRAIDBridgeCommandSetExpandProperties = @"setExpandProperties";
static NSString* MRAIDBridgeCommandSetResizeProperties = @"setResizeProperties";
static NSString* MRAIDBridgeCommandSetOrientationProperties = @"setOrientationProperties";
static NSString* MRAIDBridgeCommandPlayVideo = @"playVideo";
static NSString* MRAIDBridgeCommandCreateCalenderEvent = @"createCalendarEvent";
static NSString* MRAIDBridgeCommandStorePicture = @"storePicture";


@implementation PMMRAIDBridge

@synthesize delegate;
@synthesize needsInit;
@synthesize state, expandProperties, resizeProperties, orientationProperties;

- (void)dealloc
{
    self.delegate = nil;
}

- (void)sendErrorMessage:(NSString*)message forAction:(NSString*)action forWebView:(UIWebView*)webView;
{
    NSString* script = [NSString stringWithFormat:@"mraid.fireErrorEvent('%@','%@');", message, action];
    
    [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script waitUntilDone:YES];
}

- (void)setSupported:(BOOL)s forFeature:(PMMRAIDBridgeSupports)f forWebView:(UIWebView*)webView
{
    NSString* supported = MRAIDBridgeFalse;
    if (s)
        supported = MRAIDBridgeTrue;
    
    NSString* feature = nil;
    switch (f)
    {
        case PMMRAIDBridgeSupportsSMS:
            feature = MRAIDBridgeFeatureSMS;
            break;
        case PMMRAIDBridgeSupportsTel:
            feature = MRAIDBridgeFeatureTel;
            break;
        case PMMRAIDBridgeSupportsCalendar:
            feature = MRAIDBridgeFeatureCalendar;
            break;
        case PMMRAIDBridgeSupportsStorePicture:
            feature = MRAIDBridgeFeatureStorePicture;
            break;
        case PMMRAIDBridgeSupportsInlineVideo:
            feature = MRAIDBridgeFeatureInlineVideo;
            break;
    }
    if (feature == nil)
        return;
    
    NSString* script = [NSString stringWithFormat:@"mraid.setSupports('%@',%@);", feature, supported];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setState:(PMMRAIDBridgeState)s forWebView:(UIWebView*)webView
{
    state = s;
    
    NSString* stateString = nil;
    switch (self.state)
    {
        case PMMRAIDBridgeStateLoading:
            stateString = MRAIDBridgeSLoading;
            break;
        case PMMRAIDBridgeStateDefault:
            stateString = MRAIDBridgeSDefault;
            break;
        case PMMRAIDBridgeStateExpanded:
            stateString = MRAIDBridgeSExpanded;
            break;
        case PMMRAIDBridgeStateResized:
            stateString = MRAIDBridgeSResized;
            break;
        case PMMRAIDBridgeStateHidden:
            stateString = MRAIDBridgeSHidden;
            break;
    }
    
    NSString* script = [NSString stringWithFormat:@"mraid.setState('%@');", stateString];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)sendReadyForWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.fireEvent('%@');", MRAIDBridgeEReady];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setViewable:(BOOL)v forWebView:(UIWebView*)webView
{
    NSString* viewable = MRAIDBridgeFalse;
    if (v)
        viewable = MRAIDBridgeTrue;
    
    NSString* script = [NSString stringWithFormat:@"mraid.setViewable(%@);", viewable];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setScreenSize:(CGSize)s forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setScreenSize({width:%.0f,height:%.0f});",
                        s.width, s.height];
    
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setMaxSize:(CGSize)ms forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setMaxSize({width:%.0f,height:%.0f});",
                        ms.width, ms.height];
    
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setCurrentPosition:(CGRect)cp forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setCurrentPosition({x:%.0f,y:%.0f,width:%.0f,height:%.0f });",
                        cp.origin.x, cp.origin.y, cp.size.width, cp.size.height];
    
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setDefaultPosition:(CGRect)dp forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setDefaultPosition({x:%.0f,y:%.0f,width:%.0f,height:%.0f });", 
                        dp.origin.x, dp.origin.y, dp.size.width, dp.size.height];
    
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setPlacementType:(PMMRAIDBridgePlacementType)pt forWebView:(UIWebView*)webView
{
    NSString* ptString = nil;
    switch (pt)
    {
        case PMMRAIDBridgePlacementTypeInline:
            ptString = MRAIDBridgePTypeInline;
            break;
        case PMMRAIDBridgePlacementTypeInterstitial:
            ptString = MRAIDBridgePTypeInterstitial;
            break;
    }
    
    NSString* script = [NSString stringWithFormat:@"mraid.setPlacementType('%@');", ptString];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setExpandProperties:(PMMRAIDExpandProperties*)ep forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setExpandProperties(%@);", ep];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setResizeProperties:(PMMRAIDResizeProperties*)rp forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setResizeProperties(%@);", rp];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)setOrientationProperties:(PMMRAIDOrientationProperties*)op forWebView:(UIWebView*)webView
{
    NSString* script = [NSString stringWithFormat:@"mraid.setOrientationProperties(%@);", op];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)sendPictureAdded:(BOOL)s forWebView:(UIWebView*)webView
{
    NSString* success = MRAIDBridgeFalse;
    if (s)
        success = MRAIDBridgeFalse;
    
    NSString* script = [NSString stringWithFormat:@"mraid.firePictureAddedEvent(%@);", success];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (BOOL)parseRequest:(NSURLRequest *)request
{
    // Sample:
    // mraid://setExpandProperties?width=100&height=100
    
    NSString* scheme = request.URL.scheme;
    
    if ([scheme isEqualToString:@"mraid"] == NO)
        return NO;
    
    
    NSString* command = request.URL.host;
    NSString* query = request.URL.query;
    

    NSMutableDictionary* args = [NSMutableDictionary dictionary];
    NSArray* items = [query componentsSeparatedByString:@"&"];
    for (NSString* item in items)
    {
        NSArray* keyValue = [item componentsSeparatedByString:@"="];
        if ([keyValue count] == 2)
        {
            NSString* k = [keyValue objectAtIndex:0];
            NSString* v = [keyValue objectAtIndex:1];
            
            NSString* key = (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)k, CFSTR(""));
            NSString* value = (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)v, CFSTR(""));
            
            [args setValue:value forKey:key];
        }
    }
    
    
    if ([command isEqualToString:MRAIDBridgeCommandInit])
    {
        if  (self.delegate)
        {
            [self.delegate mraidBridgeInit:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandClose])
    {
        if  (self.delegate)
        {
            [self.delegate mraidBridgeClose:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandOpen])
    {
        if (self.delegate)
        {
            NSString* url = [args valueForKey:MRAIDBridgeArgURL];
            [self.delegate mraidBridge:self openURL:url];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandUpdateCurrentPosition])
    {
        if (self.delegate)
        {
            [self.delegate mraidBridgeUpdateCurrentPosition:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandSetExpandProperties])
    {
        PMMRAIDExpandProperties* properties = [PMMRAIDExpandProperties propertiesFromArgs:args];
        expandProperties = properties;
        
        if (self.delegate)
        {
            [self.delegate mraidBridgeUpdatedExpandProperties:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandExpand])
    {
        if (self.delegate)
        {
            NSString* url = [[args valueForKey:MRAIDBridgeArgURL] stringByRemovingPercentEncoding];
            [self.delegate mraidBridge:self expandWithURL:url];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandSetResizeProperties])
    {
        PMMRAIDResizeProperties* properties = [PMMRAIDResizeProperties propertiesFromArgs:args];
        resizeProperties = properties;
        
        if (self.delegate)
        {
            [self.delegate mraidBridgeUpdatedResizeProperties:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandResize])
    {
        if (self.delegate)
        {
            [self.delegate mraidBridgeResize:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandSetOrientationProperties])
    {
        PMMRAIDOrientationProperties* properties = [PMMRAIDOrientationProperties propertiesFromArgs:args];
        orientationProperties = properties;
        
        if (self.delegate)
        {
            [self.delegate mraidBridgeUpdatedOrientationProperties:self];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandPlayVideo])
    {
        if (self.delegate)
        {
            NSString* url = [[args valueForKey:MRAIDBridgeArgURL] stringByRemovingPercentEncoding];
            [self.delegate mraidBridge:self playVideo:url];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandCreateCalenderEvent])
    {
        if (self.delegate)
        {
            NSString* event = [args valueForKey:MRAIDBridgeArgEvent];
            [self.delegate mraidBridge:self createCalenderEvent:event];
        }
    }
    else if ([command isEqualToString:MRAIDBridgeCommandStorePicture])
    {
        if (self.delegate)
        {
            NSString* url = [[args valueForKey:MRAIDBridgeArgURL] stringByRemovingPercentEncoding];
            [self.delegate mraidBridge:self storePicture:url];
        }
    }

    return YES;
}


@end
