//
//  ViewController.m
//  SampleAS24PubMaticCocoaPods
//
//  Created by Böhler Jan on 30.04.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "ViewController.h"
#import "VehicleCell.h"
//#import "PubMaticCell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
//    [self.tableView registerClass:[VehicleCell class] forCellReuseIdentifier:@"VehicleCell"];
//    [self.tableView registerClass:[PubMaticCell class] forCellReuseIdentifier:@"PubMaticCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isPubMatiCell = [self isPubMatiCellAtIndexPath:indexPath];
    NSString *cellIdentifier = isPubMatiCell ? @"PubMaticCell" : @"VehicleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isPubMatiCell = [self isPubMatiCellAtIndexPath:indexPath];
    if(isPubMatiCell) {
        return 160;
    }
    return 150;
}

- (BOOL)isPubMatiCellAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row % 10 == 9;
}


@end
