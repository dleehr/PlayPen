//
//  ProgressViewController.m
//  PlayPen
//
//  Created by Dan Leehr on 8/8/15.
//  Copyright (c) 2015 Dan Leehr. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ProgressViewController

+ (instancetype)progressViewControllerWithTitle:(NSString *)title {
    ProgressViewController *instance = [super alertControllerWithTitle:title
                                                               message:@""
                                                        preferredStyle:UIAlertControllerStyleAlert];
    return instance;
}

- (void)setProgress:(float)progress {
    self.progressView.progress = progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    static CGFloat sideMargin = 16.0f;
    static CGFloat magicYOffset = 53.0f; // could I base this on the size of the message?
    static CGFloat height = 2.0f;
    progressView.frame = CGRectMake(  CGRectGetMinX(self.view.bounds) + sideMargin
                                         , CGRectGetMinY(self.view.bounds) + magicYOffset
                                         , CGRectGetWidth(self.view.bounds) - 2.0f * sideMargin
                                         , height);
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:progressView];
    self.progressView = progressView;

}

@end
