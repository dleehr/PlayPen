//
//  ViewController.m
//  PlayPen
//
//  Created by Dan Leehr on 8/6/15.
//  Copyright (c) 2015 Dan Leehr. All rights reserved.
//

#import "ViewController.h"
#import "ProgressViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIBarButtonItem *startButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) ProgressViewController *progressViewController;

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
    self.label.numberOfLines = 0;
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
    self.progress = progress;
    [progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(localizedDescription))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [progress becomeCurrentWithPendingUnitCount:1];
    [self showProgress];
    // start the task
    [self performTaskWithCompletionBlock:^{
        [self done:progress.cancelled];
    }];
    [progress resignCurrent];
}

- (void)done:(BOOL)cancelled {
    self.navigationItem.rightBarButtonItem = self.startButton;
    if (self.progressViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [self.progress removeObserver:self
                       forKeyPath:NSStringFromSelector(@selector(localizedDescription))
                          context:NULL];
    self.progress = nil;
}

- (void)cancel:(id)sender {
    // cancel the thing
    [self.progress cancel];
}

- (void)showProgress {
    ProgressViewController *progressViewController = [ProgressViewController progressViewControllerWithTitle:@"Cloning DLSFTPClient"];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             [self cancel:nil];
                                                         }];
    [progressViewController addAction:cancelAction];
    self.progressViewController = progressViewController;
    [self presentViewController:progressViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performTaskWithCompletionBlock:(dispatch_block_t)completionBlock {
    // getting progress needs to happen on the same thread
    NSProgress *taskProgress = [NSProgress progressWithTotalUnitCount:-1];
    taskProgress.cancellable = YES;
    taskProgress.pausable = NO;
    taskProgress.totalUnitCount = 100;
    taskProgress.kind = NSProgressKindFile;
    [taskProgress setUserInfoObject:@(100) forKey:NSProgressFileTotalCountKey];
    [taskProgress setUserInfoObject:NSProgressFileOperationKindReceiving forKey:NSProgressFileOperationKindKey];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [taskProgress becomeCurrentWithPendingUnitCount:1];
        // This should be on a different queue
        // update the total unit count
        for (NSUInteger i=0; i<100; i++) {
            usleep(USEC_PER_SEC / 10);
            if (taskProgress.isCancelled) {
                [taskProgress resignCurrent];
                return;
            }
            taskProgress.completedUnitCount = i+1;
        }
        [taskProgress resignCurrent];
    }];
    operation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), completionBlock);
    };
    [self.queue addOperation:operation];
    
}

# pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSProgress *progress = object;
    NSLog(@"Progress: %@", progress);
    NSString *text = [NSString stringWithFormat:@"%@\n%@", [object localizedDescription], [object localizedAdditionalDescription]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = text;
        [self.progressViewController setProgress:progress.fractionCompleted];
    });
}

@end
