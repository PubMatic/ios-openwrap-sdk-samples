/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2020 PubMatic, All Rights Reserved.
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
#define DUMMY_AD_SERVER_ADUNIT_ID  @"OtherASInterstitialAdUnit"
#define OW_ADUNIT_ID    @"OtherASInterstitialAdUnit"
#define PUB_ID          @"156276"
#define PROFILE_ID      @1757

#import "VideoInterstitialViewController.h"
#import "CustomInterstitialEventHandler.h"
@import OpenWrapSDK;

@interface VideoInterstitialViewController ()<POBInterstitialDelegate,POBInterstitialVideoDelegate>
@property (nonatomic) POBInterstitial *interstitial;
@property (nonatomic) IBOutlet UIButton *showAdButton;
@end

@implementation VideoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an interstitial custom event handler for your ad server. Make sure
    // you use separate event handler objects to create each interstitial ad instance.
    // For example, The code below creates an event handler for DummyAdServer.
    CustomInterstitialEventHandler *eventHandler = [[CustomInterstitialEventHandler alloc] initWithAdUnit:DUMMY_AD_SERVER_ADUNIT_ID];
    
    // Create an interstitial object
    // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
    self.interstitial = [[POBInterstitial alloc]
                                 initWithPublisherId:PUB_ID
                                 profileId:PROFILE_ID
                                 adUnitId:OW_ADUNIT_ID
                         eventHandler:eventHandler];
    // Set the delegate
    self.interstitial.delegate = self;
    
    // Set video delegate to receive VAST based video events
    self.interstitial.videoDelegate = self;
}

- (IBAction)loadAdAction:(id)sender {
    // Load Ad
    [self.interstitial loadAd];
}

- (IBAction)showAdAction:(id)sender {
    [self showInterstitialAd];
}

// To show interstitial ad call this method
- (void)showInterstitialAd{
    // ...
    if (self.interstitial.isReady) {
        // Show interstitial ad
        [self.interstitial showFromViewController:self];
    }
}

#pragma mark - Interstitial delegate methods

// Notifies the delegate that an ad has been received successfully.
- (void)interstitialDidReceiveAd:(nonnull POBInterstitial *)interstitial {
    self.showAdButton.hidden = NO;
    NSLog(@"Interstitial : Ad Received");
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)interstitial:(nonnull POBInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Interstitial : Ad failed with error : %@", error.localizedDescription);
}

// Notifies the delegate that the interstitial ad will be presented as a modal on top of the current view controller.
- (void)interstitialWillPresentAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Will present");
}

// Notifies the delegate that the interstitial ad has been animated off the screen.
- (void)interstitialDidDismissAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Dismissed");
}

// Notifies the delegate of ad click
- (void)interstitialDidClickAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Ad Clicked");
}

// Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
- (void)interstitialWillLeaveApplication:(nonnull POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Will leave app");
}

// Notifies the delegate of an ad expiration. After this callback, this 'POBInterstitial' instance is marked as invalid & will not be shown.
- (void)interstitialDidExpireAd:(POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Ad Expired");
}

#pragma mark - POBInterstitialVideoDelegate

// Notifies the delegate of VAST based video ad events
- (void)interstitialDidFinishVideoPlayback:(POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Finished video playback");
}

#pragma mark - dealloc
- (void)dealloc {
    self.interstitial = nil;
}
@end


