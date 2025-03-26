/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical
 * concepts contained herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in
 * process, and are protected by trade secret or copyright law. Dissemination of this information or reproduction of
 * this material is strictly forbidden unless prior written permission is obtained from PubMatic.  Access to the source
 * code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors
 * who have executed Confidentiality and Non-disclosure agreements explicitly covering such access or to such other
 * persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and
 * nondisclosure obligations with respect to the source code.
 *
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code,
 * which includes information that is confidential and/or proprietary, and is a trade secret, of  PubMatic. ANY
 * REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE
 * CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE LAWS
 * AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT
 * CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL
 * ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

#import "BaseViewController.h"
#import "OpenWrapSDK/OpenWrapSDK.h"

#pragma mark - Utils

/** Ensures that the operation is performed on the main thread. */
void performOnMainThread(void (^operation)(void)) {
    if (NSThread.isMainThread) {
        operation();
    } else {
        dispatch_async(dispatch_get_main_queue(), operation);
    }
};

#pragma mark - BaseViewController

@interface BaseViewController ()

@property (nonatomic, strong, nullable) IBOutlet UITextView *logTextView;

@end

@implementation BaseViewController

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self log:@"OpenWrap SDK Version : %@", [OpenWrapSDK version]];
}

#pragma mark Public APIs

- (void)log:(NSString *)format, ... {
    if (!format) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *const message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"%@", message);
    typeof(self) __weak weakSelf = self;
    performOnMainThread(^{
        typeof(weakSelf) __strong strongSelf = weakSelf;
        strongSelf.logTextView.text = [strongSelf.logTextView.text stringByAppendingFormat:@"%@\n", message];
    });
}

#pragma mark View Appearance

+ (void)updateLogTextView:(UITextView *)logTextView {
    [logTextView setEditable:NO];
    logTextView.text = @"";
}

#pragma mark Accessors

- (void)setLogTextView:(UITextView *)logTextView {
    _logTextView = logTextView;
    [BaseViewController updateLogTextView:logTextView];
}

@end
