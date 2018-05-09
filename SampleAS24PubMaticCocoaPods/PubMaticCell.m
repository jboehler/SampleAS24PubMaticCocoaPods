//
//  PubMaticCell.m
//  SampleAS24PubMatic
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "PubMaticCell.h"

@interface PubMaticCell ()
@property (nonatomic) PMBannerAdView *adView;
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
    CGRect frame = CGRectMake(0, 0, 320, 50);
    self.adView = [self adviewWithFrame: frame];
    [self addSubview:self.adView];
    self.contentView.backgroundColor = UIColor.magentaColor;
}

-(PMBannerAdView *)adviewWithFrame:(CGRect)frame{
    PMBannerAdView * adView= [[PMBannerAdView alloc] initWithFrame:frame] ;
    adView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
//    adView.useInternalBrowser = [[Settings sharedInstance] useInternalBrowser];
    [adView setDelegate:self];
    return adView;
}

- (BOOL)bannerAdViewSupportsSMS:(PMBannerAdView*)adView {
    return NO;
}

- (BOOL)bannerAdViewSupportsPhone:(PMBannerAdView*)adView {
    return NO;
}

- (BOOL)bannerAdViewSupportsCalendar:(PMBannerAdView*)adView {
    return NO;
}

- (BOOL)bannerAdViewSupportsStorePicture:(PMBannerAdView*)adView {
    return NO;
}

@end
