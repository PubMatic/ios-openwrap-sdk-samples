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

#import "MoPubBannerViewController.h"
#import <POBBannerView.h>
#import <MoPubBannerEventHandler.h>

#define PUB_ID          @"156276"
#define PROFILE_ID      @1302
#define MOPUB_AD_UNIT  @"7bb033b5e2404ab9a1f907702447b4b9"
#define OW_AD_UNIT  @"7bb033b5e2404ab9a1f907702447b4b9"

@interface MoPubBannerViewController ()<POBBannerViewDelegate>
@property (nonatomic) POBBannerView *bannerView;
@end

@implementation MoPubBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a banner custom event handler for your ad server. Make sure you use
    // separate event handler objects to create each banner view.
    // For example, The code below creates an event handler for MoPub ad server.
    CGSize size = CGSizeMake(320.0, kMPPresetMaxAdSize50Height.height);
    MoPubBannerEventHandler *eventHandler = [[MoPubBannerEventHandler alloc] initWithAdUnitId:MOPUB_AD_UNIT adSize:size];
    
    // Create a banner view
    // For test IDs refer - https://community.pubmatic.com/x/_xQ5AQ#TestandDebugYourIntegration-TestProfile/Placements
    self.bannerView = [[POBBannerView alloc]
                       initWithPublisherId:PUB_ID
                       profileId:PROFILE_ID
                       adUnitId:OW_AD_UNIT
                       eventHandler:eventHandler];
    
    // Set the delegate
    self.bannerView.delegate = self;
    
    // Add the banner view to your view hierarchy
    [self addBannerToView:self.bannerView withSize:size];
    
    // Load Ad
    [self.bannerView loadAd];
}

- (void)addBannerToView:(UIView *)bannerView withSize:(CGSize )size{
    bannerView.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-size.width)/2,
                                  CGRectGetHeight(self.view.bounds)-size.height,
                                  size.width, size.height);
    bannerView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                   UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleRightMargin);
    [self.view addSubview:bannerView];
}

#pragma mark - Banner view delegate methods
//Provides a view controller to use for presenting model views
- (UIViewController *)bannerViewPresentationController {
    return self;
}

// Notifies the delegate that an ad has been successfully loaded and rendered.
- (void)bannerViewDidReceiveAd:(POBBannerView *)bannerView {
    NSLog(@"Banner : Ad received with size %@ ", bannerView.creativeSize);
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)bannerView:(POBBannerView *)bannerView
didFailToReceiveAdWithError:(NSError *_Nullable)error {
    NSLog(@"Banner : Ad failed with error : %@", [error localizedDescription]);
}

// Notifies the delegate whenever current app goes in the background due to user click
- (void)bannerViewWillLeaveApplication:(POBBannerView *)bannerView {
    NSLog(@"Banner : Will leave app");
}

// Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
- (void)bannerViewWillPresentModal:(POBBannerView *)bannerView {
    NSLog(@"Banner : Will present modal");
}

// Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
- (void)bannerViewDidDismissModal:(POBBannerView *)bannerView {
    NSLog(@"Banner : Dismissed modal");
}

#pragma mark - dealloc
- (void)dealloc {
    _bannerView = nil;
}

@end
