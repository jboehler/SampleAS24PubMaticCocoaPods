//
//  PubMaticCell.h
//  SampleAS24PubMatic
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PubMaticSDK/PMBannerAdView.h>

@interface PubMaticCell : UITableViewCell <PMBannerAdViewDelegate>
@property (nonatomic) PMBannerAdView *adView;
- (void)loadRequest;
@end
