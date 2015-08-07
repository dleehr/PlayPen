//
//  ViewController.m
//  PlayPen
//
//  Created by Dan Leehr on 8/6/15.
//  Copyright (c) 2015 Dan Leehr. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIBarButtonItem *startButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.label = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.label];
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.startButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(start:)];
    self.navigationItem.rightBarButtonItem = self.startButton;
}

- (void)start:(id)sender {
    if (self.progress) {
        return;
    }
    self.navigationItem.rightBarButtonItem = self.cancelButton;
    // start the thing
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:1];
    progress.cancellationHandler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = self.startButton;
        });
    };
    self.progress = progress;
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [progress becomeCurrentWithPendingUnitCount:1];
    // start the task
    [self performTaskWithCompletionBlock:^{
        [progress removeObserver:self
                      forKeyPath:@"fractionCompleted"
                         context:NULL];
        self.progress = nil;
    }];
    [progress resignCurrent];
}

- (void)cancel:(id)sender {
    // cancel the thing
    [self.progress cancel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performTaskWithCompletionBlock:(dispatch_block_t)completionBlock {
    // This needs to happen before the other progress resigns
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:10];
    progress.cancellable = YES;
    progress.pausable = NO;

    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (NSUInteger i=0; i<10; i++) {
            sleep(1);
            if (progress.isCancelled) {
                return;
            }
            progress.completedUnitCount++;
        }
    }];
    operation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), completionBlock);
    };
    [self.queue addOperation:operation];
    
}

# pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSString *text = [object localizedDescription];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = text;
    });
}

@end
