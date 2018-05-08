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
//  PMBannerAdView
//
//  Created on 9/21/12.

//

#import "PMAdBrowser.h"
#import "PMBrowserBackPNG.h"
#import "PMBrowserForwardPNG.h"
#import "PMSDKUtil.h"
#import "PMError.h"

@interface PMAdBrowser () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) UIToolbar* toolbar;
@property (nonatomic, strong) UIBarButtonItem* backButton;
@property (nonatomic, strong) UIBarButtonItem* forwardButton;
@end

@implementation PMAdBrowser

@synthesize delegate, URL;
@synthesize webView, toolbar, backButton, forwardButton;

- (void)dealloc
{
    [self.webView stopLoading];
    self.webView.delegate = nil;
    self.webView = nil;
    self.toolbar = nil;
    self.backButton = nil;
    self.forwardButton = nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.toolbar == nil)
    {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 44,
                                                                   CGRectGetWidth(self.view.bounds), 44)];
        
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        self.toolbar.barStyle = UIBarStyleBlack;
        
        NSMutableArray* items = [NSMutableArray array];
        
        // Close
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                              target:self
                                                                              action:@selector(toolbarClose:)];
        [items addObject:item];
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        // Back
        NSData* buttonData = [NSData dataWithBytesNoCopy:PMBrowserBack_png
                                                  length:PMBrowserBack_png_len
                                            freeWhenDone:NO];
        
        UIImage* buttonImage = [UIImage imageWithData:buttonData];
        buttonImage = [UIImage imageWithCGImage:buttonImage.CGImage
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
        
        item = [[UIBarButtonItem alloc] initWithImage:buttonImage
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(toolbarBack:)];
        
        [items addObject:item];
        self.backButton = item;
        self.backButton.enabled = NO;        

        // Forward
        buttonData = [NSData dataWithBytesNoCopy:PMBrowserForward_png
                                          length:PMBrowserForward_png_len
                                    freeWhenDone:NO];
        
        buttonImage = [UIImage imageWithData:buttonData];
        buttonImage = [UIImage imageWithCGImage:buttonImage.CGImage
                                          scale:2.0
                                    orientation:UIImageOrientationUp];

        item = [[UIBarButtonItem alloc] initWithImage:buttonImage
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(toolbarForward:)];
        [items addObject:item];
        self.forwardButton = item;
        self.forwardButton.enabled = NO;
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        
        // Reload
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                             target:self
                                                             action:@selector(toolbarReload:)];
        [items addObject:item];
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        
        // Action
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                             target:self
                                                             action:@selector(toolbarAction:)];
        [items addObject:item];
        
        
        self.toolbar.items = items;
    }
    
    if (self.webView == nil)
    {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.webView.delegate = self;
        self.webView.allowsInlineMediaPlayback = YES;
        self.webView.mediaPlaybackRequiresUserAction = YES;
    }
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.toolbar];
}

- (void)setURL:(NSURL *)url
{
    URL = [url copy];
    [self load];
}

- (void)load
{
    if (self.isViewLoaded == NO)
        return;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.URL
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:10];
    self.webView.scalesPageToFit=YES;

    [self.webView loadRequest:request];
}

#pragma mark - Toolbar Selectors

- (void)toolbarClose:(id)sender
{
    [self.delegate browserDidClose:self];
}

- (void)toolbarBack:(id)sender
{
    [self.webView goBack];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarForward:(id)sender
{
    [self.webView goForward];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarReload:(id)sender
{
    [self.webView reload];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarAction:(id)sender
{
    [self.delegate browserWillLeaveApplication:self];
    [PMSDKUtil openURL:[self.webView.request URL]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    [self.delegate browser:self didFailLoadWithError:[PMError errorWithCode:kPMErrorInternalError description:error.localizedDescription]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* host = [request.URL.host lowercaseString];

    if ([host hasSuffix:@"itunes.apple.com"] || [host hasSuffix:@"phobos.apple.com"])
    {
        [self.delegate browserWillLeaveApplication:self];
        [PMSDKUtil openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
