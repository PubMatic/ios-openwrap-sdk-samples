/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
* herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
* from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
* Confidentiality and Non-disclosure agreements explicitly covering such access or to such other persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
* information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
* OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
* LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
* TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
*/

#define OW_ADUNIT_ID    @"OpenWrapAppOpenAdUnit"
#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

#import "AppOpenAdViewController.h"
@import OpenWrapSDK;

@interface AppOpenAdViewController ()<POBAppOpenAdDelegate>
@property (nonatomic) POBAppOpenAd *appOpenAd;
@property (nonatomic) IBOutlet UIButton *showAdButton;
@end

@implementation AppOpenAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an app open ad object
    // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
    self.appOpenAd = [[POBAppOpenAd alloc]
                                 initWithPublisherId:PUB_ID
                                 profileId:PROFILE_ID
                                 adUnitId:OW_ADUNIT_ID];
    // Set the delegate
    self.appOpenAd.delegate = self;
}

- (IBAction)loadAdAction:(id)sender {
    // Load Ad
    [self.appOpenAd loadAd];
}

- (IBAction)showAdAction:(id)sender {
    [self showAppOpenAd];
}

// To show App Open Ad call this method
- (void)showAppOpenAd{
    if (self.appOpenAd.isReady) {
        // Show App Open Ad ad
        [self.appOpenAd showFromViewController:self];
    }
}

#pragma mark - App Open Ad delegate methods

// Notifies the delegate that an ad has been received successfully.
- (void)appOpenAdDidReceiveAd:(nonnull POBAppOpenAd *)appOpenAd {
    [self.showAdButton setEnabled:YES];
    [self log:@"App Open Ad : Ad Received"];
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)appOpenAd:(nonnull POBAppOpenAd *)appOpenAd didFailToReceiveAdWithError:(NSError *)error {
    [self log:@"App Open Ad : Failed to receive ad with error : %@", error.localizedDescription];
}

// Notifies the delegate of an error encountered while showing an ad.
- (void)appOpenAd:(POBAppOpenAd *)appOpenAd didFailToShowAdWithError:(NSError *)error {
    [self log:@"App Open Ad : Failed to show ad with error : %@", error.localizedDescription];
}

// Notifies the delegate that the app open ad will be presented as a modal on top of the current view controller.
- (void)appOpenAdWillPresentAd:(POBAppOpenAd * _Nonnull)appOpenAd {
    [self log:@"App Open Ad : Will present"];
}

// Notifies the delegate that the app open ad is presented as a modal on top of the current view controller.
- (void)appOpenAdDidPresentAd:(POBAppOpenAd * _Nonnull)appOpenAd {
    [self log:@"App Open Ad : Did present"];
}

// Notifies the delegate that the app open ad has been animated off the screen.
- (void)appOpenAdDidDismissAd:(POBAppOpenAd * _Nonnull)appOpenAd {
    [self log:@"App Open Ad : Dismissed"];
}

// Notifies the delegate of ad click
- (void)appOpenAdDidClickAd:(POBAppOpenAd * _Nonnull)appOpenAd {
    [self log:@"App Open Ad : Ad Clicked"];
}

// Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
- (void)appOpenAdWillLeaveApplication:(nonnull POBAppOpenAd *)appOpenAd {
    [self log:@"App Open Ad : Will leave app"];
}

- (void)appOpenAdDidRecordImpression:(POBAppOpenAd *)appOpenAd {
    [self log:@"App Open Ad : Ad Impression"];
}

#pragma mark - dealloc
- (void)dealloc {
    self.appOpenAd = nil;
}
@end



