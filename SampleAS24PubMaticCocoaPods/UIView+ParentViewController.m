//
//  UIView+ParentViewController.m
//  SampleAS24PubMaticCocoaPods
//
//  Created by Böhler Jan on 16.05.18.
//  Copyright © 2018 Scout24. All rights reserved.
//

#import "UIView+ParentViewController.h"

@implementation UIView (ParentViewController)

-(UIViewController *)parentViewController {
    //Go up in responder hierarchy until we reach a ViewController or return nil
    //if we don't find one
    id object = [self nextResponder];
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    return object;
}

@end
