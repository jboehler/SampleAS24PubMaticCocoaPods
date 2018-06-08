//
//  PubMaticCell.m
//  SampleAS24PubMatic
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "PubMaticCell.h"
#import "UIView+ParentViewController.h"
#import <CommonCrypto/CommonDigest.h>
//#import "Settings.h"

@interface PubMaticCell ()<PMBannerAdViewDelegate>
@property (nonatomic) int count;
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
        self.count = 0;
    }
    return self;
}

- (void)initialise {
    [self initialiseAdView];
}

- (void)initialiseAdView {
    [self.adView removeFromSuperview];
    CGRect frame = CGRectMake(0, 0, PMBANNER_SIZE_300x250.width, PMBANNER_SIZE_300x250.height);
    self.adView = [self adviewWithFrame: frame];
    [self.contentView addSubview:self.adView];
    
    // DEBUGING COLOR
    self.adView.backgroundColor = UIColor.orangeColor;
    self.contentView.backgroundColor = UIColor.magentaColor;
}

- (NSString *)sha1: (NSString *)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
    
- (PMBannerAdView *)adviewWithFrame:(CGRect)frame{
    PMBannerAdView * adView= [[PMBannerAdView alloc] initWithFrame:frame];
    adView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
    //self.adView.useInternalBrowser = [[Settings sharedInstance] useInternalBrowser];
    adView.delegate = self;
    return adView;
}

- (void)loadRequest {
    PMBannerAdRequest *bannerAdReques = [self bannerAdRequest];
//    [[Settings sharedInstance] setAdRequest:bannerAdReques];
    [self.adView loadRequest:bannerAdReques];
}

- (void)reloadAdView {
    [self initialiseAdView];
    [self loadRequest];
}

- (void)didGetPubmticResponse {
    if(self.count > 2500) {
        return;
    }
    self.count += 1;
    NSLog(@"did did get response from pubmatic");
    NSLog(@"count: %d", self.count);
    int delay = arc4random() % 2000 / 100; //  300 / 100 =max 3.0 min 0.0 
    [self performSelector:@selector(reloadAdView) withObject:nil afterDelay:delay];
    
    
}

#pragma mark - PMBannerAdViewDelegate methods
- (void)bannerAdViewDidRecieveAd:(PMBannerAdView *)adView{
//    [[Settings sharedInstance] setAdResponse:[adView valueForKey:@"adResponse"]];
//    [self showIndicator:NO];
    
    [self didGetPubmticResponse];
}

- (void)bannerAdView:(PMBannerAdView *)adView didFailToReceiveAdWithError:(PMError *)error{
    
//    [[Settings sharedInstance] setAdResponse:[adView valueForKey:@"adResponse"]];
    NSString *errMsg = [NSString stringWithFormat:@"Error code: %ld Description: %@",(long)error.code, [error localizedDescription]];
    NSLog(@"%@",errMsg);
//    [self showIndicator:NO];
//    [self.view makeToast:errMsg];
    
    [self didGetPubmticResponse];
}

- (PMBannerAdRequest *)bannerAdRequest {
    NSString *pubId = @"156157";
    NSString *siteId = @"285059";
    NSString *adtagId = @"1373483";
//        NSString *pubId = @"31400";
//        NSString *siteId = @"32504";
//        NSString *adtagId = @"439662";
    
    PMBannerAdRequest *bannerAdReques = [[PMBannerAdRequest alloc] initWithPublisherId:pubId siteId:siteId adId:adtagId];
    
//    int randomUserID = [self sha1:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
    bannerAdReques.isIDFAEnabled = NO;
    bannerAdReques.udidHashType = PMUdidhashTypeSHA1;
    
    NSArray<NSDictionary<NSString *, NSString *> *> *location = @[@{@"city": @"Bern", @"zip": @"3000"},
                          @{@"city": @"Zurich", @"zip": @"8000"},
                          @{@"city": @"Flamatt", @"zip": @"3175"},
                          @{@"city": @"Basel", @"zip": @"4000"},
                          @{@"city": @"Luzern", @"zip": @"6000"},
                          @{@"city": @"Genf", @"zip": @"1200"}];
    
    int index = arc4random() % location.count;
    
    bannerAdReques.city = location[index][@"city"];
    bannerAdReques.zip = location[index][@"zip"];
    
    
    
    NSLog(@"request location: %@", location[index]);
    
    bannerAdReques.adSize = PMBANNER_SIZE_300x250; //CGSizeMake([Settings sharedInstance].adWidth, [Settings sharedInstance].adHeight);
//    for (NSDictionary * pair in [Settings sharedInstance].customParameters) {
//        NSString * key = [[pair allKeys] firstObject];
//        [bannerAdReques setCustomParam:[pair objectForKey:key] forKey:key];
//    }
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
