//
//  VehicleCell.m
//  SampleAS24PubMatic
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "VehicleCell.h"

@implementation VehicleCell

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
    self.contentView.backgroundColor = UIColor.cyanColor;
}


@end
