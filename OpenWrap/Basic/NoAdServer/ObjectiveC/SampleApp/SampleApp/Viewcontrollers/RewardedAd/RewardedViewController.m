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

#define OW_ADUNIT_ID    @"OpenWrapRewardedAdUnit"
#define PUB_ID          @"156276"
#define PROFILE_ID      @1757

#import "RewardedViewController.h"
@import OpenWrapSDK;

@interface RewardedViewController ()<POBRewardedAdDelegate>
@property (nonatomic) POBRewardedAd *rewardedAd;
@property (nonatomic) IBOutlet UIButton *showAdButton;
@end

@implementation RewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a Rewarded object
    // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
    self.rewardedAd = [POBRewardedAd rewardedAdWithPublisherId:PUB_ID profileId:PROFILE_ID adUnitId:OW_ADUNIT_ID];
    // Set the delegate
    self.rewardedAd.delegate = self;
}

- (IBAction)loadAdAction:(id)sender {
    // Load Ad
    [self.rewardedAd loadAd];
}

- (IBAction)showAdAction:(id)sender {
    [self showRewardedAd];
}

// To show Rewarded ad call this method
- (void)showRewardedAd{
    // ...
    if (self.rewardedAd.isReady) {
        // Show Rewarded ad
        [self.rewardedAd showFromViewController:self];
    }
}

#pragma mark - Rewarded delegate methods

// Notifies the delegate that an rewarded ad has been received successfully.
- (void)rewardedAdDidReceiveAd:(POBRewardedAd *)rewardedAd{
    [self.showAdButton setEnabled:YES];
    [self log:@"RewardedAd : Ad Received"];
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)rewardedAd:(POBRewardedAd *)rewardedAd didFailToReceiveAdWithError:(NSError *)error{
    [self log:@"RewardedAd : Failed to receive ad with error : %@", error.localizedDescription];
}

// Notifies the delegate of an error encountered while rendering an ad.
- (void)rewardedAd:(POBRewardedAd *)rewardedAd didFailToShowAdWithError:(NSError *)error {
    [self log:@"RewardedAd : Failed to show ad with error : %@", error.localizedDescription];
}

// Notifies the delegate that the rewarded ad will be presented as a modal on top of the current view controller.
- (void)rewardedAdWillPresentAd:(POBRewardedAd *)rewardedAd{
    [self log:@"RewardedAd : Will present"];
}

// Notifies the delegate that the rewarded ad has been animated off the screen.
- (void)rewardedAdDidDismissAd:(POBRewardedAd *)rewardedAd{
    [self log:@"RewardedAd : Dismissed"];
}

// Notifies the delegate of ad click
- (void)rewardedAdDidClickAd:(POBRewardedAd *)rewardedAd {
    [self log:@"RewardedAd : Ad Clicked"];
}

// Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
- (void)rewardedAdWillLeaveApplication:(POBRewardedAd *)rewardedAd {
    [self log:@"RewardedAd : Will leave app"];
}

// Notifies the delegate of an ad expiration. After this callback, this 'POBRewardedAd' instance is marked as invalid & will not be shown.
- (void)rewardedAdDidExpireAd:(POBRewardedAd *)rewardedAd {
    [self log:@"RewardedAd : Expired"];
}

// Notifies the delegate that a user will be rewarded once the ad is completely viewed.
- (void)rewardedAd:(POBRewardedAd *)rewardedAd shouldReward:(POBReward *)reward {
    [self log:@"RewardedAd : Should reward - %@(%@)", [reward.amount stringValue], reward.currencyType];
}

- (void)rewardedAdDidRecordImpression:(POBRewardedAd *)rewardedAd {
    [self log:@"RewardedAd : Ad Impression"];
}

#pragma mark - dealloc
- (void)dealloc {
    _rewardedAd = nil;
}
@end


