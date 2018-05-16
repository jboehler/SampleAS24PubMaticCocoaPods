//
//  PubMaticCell.m
//  SampleAS24PubMatic
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "PubMaticCell.h"
#import "UIView+ParentViewController.h"
#import "Settings.h"

@interface PubMaticCell ()<PMBannerAdViewDelegate>
@end

@implementation PubMaticCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initialise];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self initialise];
    }
    return self;
}

- (void)initialise {
    [self initialiseAdView];
}

- (void)initialiseAdView {
    CGRect frame = CGRectMake(0, 0, [Settings sharedInstance].adWidth, [Settings sharedInstance].adHeight);
    self.adView = [self adviewWithFrame: frame];
    [self.contentView addSubview:self.adView];
    
    // DEBUGING COLOR
    self.adView.backgroundColor = UIColor.orangeColor;
    self.contentView.backgroundColor = UIColor.magentaColor;
}
    
- (PMBannerAdView *)adviewWithFrame:(CGRect)frame{
    PMBannerAdView * adView= [[PMBannerAdView alloc] initWithFrame:frame];
    adView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    self.adView.useInternalBrowser = [[Settings sharedInstance] useInternalBrowser];
    self.adView.delegate = self;
    return adView;
}

- (void)loadRequest {
    PMBannerAdRequest *bannerAdReques = [self bannerAdRequest];
    [[Settings sharedInstance] setAdRequest:bannerAdReques];
    [self.adView loadRequest:bannerAdReques];
}

#pragma mark - PMBannerAdViewDelegate methods
- (void)bannerAdViewDidRecieveAd:(PMBannerAdView *)adView{
    
    [[Settings sharedInstance] setAdResponse:[adView valueForKey:@"adResponse"]];
//    [self showIndicator:NO];
}

- (void)bannerAdView:(PMBannerAdView *)adView didFailToReceiveAdWithError:(PMError *)error{
    
    [[Settings sharedInstance] setAdResponse:[adView valueForKey:@"adResponse"]];
    NSString *errMsg = [NSString stringWithFormat:@"Error code: %ld Description: %@",(long)error.code, [error localizedDescription]];
    NSLog(@"%@",errMsg);
//    [self showIndicator:NO];
//    [self.view makeToast:errMsg];
}

- (PMBannerAdRequest *)bannerAdRequest {
    NSString *pubId = @"31400";
    NSString *siteId = @"32504";
    NSString *adtagId = @"439662";
    PMBannerAdRequest *bannerAdReques = [[PMBannerAdRequest alloc] initWithPublisherId:pubId siteId:siteId adId:adtagId];
    [bannerAdReques setCity:[Settings sharedInstance].city];
    [bannerAdReques setZip:[Settings sharedInstance].zipCode];
    bannerAdReques.adSize = CGSizeMake([Settings sharedInstance].adWidth, [Settings sharedInstance].adHeight);
    for (NSDictionary * pair in [Settings sharedInstance].customParameters) {
        NSString * key = [[pair allKeys] firstObject];
        [bannerAdReques setCustomParam:[pair objectForKey:key] forKey:key];
    }
    return bannerAdReques;
}
    

// PMBannerAdViewDelegate

- (UIViewController*)bannerAdViewPresentationController:(PMBannerAdView*)adView
{    
    return self.parentViewController;
}

- (BOOL)bannerAdViewSupportsCalendar:(PMBannerAdView *)adView
{
    return NO;
}

-(BOOL)bannerAdView:(PMBannerAdView *)adView shouldSaveCalendarEvent:(EKEvent *)event inEventStore:(EKEventStore *)eventStore
{
    return NO;
}

- (BOOL)bannerAdViewSupportsStorePicture:(PMBannerAdView*)adView{
    return  NO;
}

-(BOOL)bannerAdView:(PMBannerAdView *)adView shouldSavePhotoToCameraRoll:(UIImage *)image
{
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)bannerAdView:(PMBannerAdView*)adView shouldPlayVideo:(NSString*)videoUR{
    
    return NO;
}

- (BOOL)bannerAdViewSupportsSMS:(PMBannerAdView*)adView{
    return NO;
}

- (BOOL)bannerAdViewSupportsPhone:(PMBannerAdView*)adView{
    return NO;
}

@end
