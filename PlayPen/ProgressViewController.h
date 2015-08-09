//
//  ProgressViewController.h
//  PlayPen
//
//  Created by Dan Leehr on 8/8/15.
//  Copyright (c) 2015 Dan Leehr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressViewController : UIAlertController

+ (instancetype)progressViewControllerWithTitle:(NSString *)title;
- (void)setProgress:(float)progress;

@end
