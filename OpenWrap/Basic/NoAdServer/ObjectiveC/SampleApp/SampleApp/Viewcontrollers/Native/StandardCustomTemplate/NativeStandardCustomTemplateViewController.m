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

#import "NativeStandardCustomTemplateViewController.h"

#define OW_ADUNIT_ID  @"OpenWrapNativeAdUnit"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

@import OpenWrapSDK;

@interface NativeStandardCustomTemplateViewController () <POBNativeAdLoaderDelegate, POBNativeAdDelegate>
@property (nonatomic, strong) POBNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) id<POBNativeAd> nativeAd;
@property (nonatomic, strong) POBNativeAdView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIButton *renderAdButton;
@end

@implementation NativeStandardCustomTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create the Native Ad Loader with desired template type (in this case, medium).
    // For test IDs refer -
    // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
    self.nativeAdLoader = [[POBNativeAdLoader alloc] initWithPublisherId:PUB_ID 
                                                               profileId:PROFILE_ID
                                                                adUnitId:OW_ADUNIT_ID
                                                            templateType:POBNativeTemplateTypeMedium];

    // Set the delegate.
    self.nativeAdLoader.delegate = self;
}

- (void)dealloc{
    _nativeAdView = nil;
    _nativeAd = nil;
    _nativeAdLoader = nil;
}

#pragma mark - UI Button actions

- (IBAction)loadAdButtonAction:(id)sender {
    // Close previously shown native ad if any
    [self closeNativeAd];
    [self.renderAdButton setEnabled:NO];

    // Load ad.
    [self.nativeAdLoader loadAd];
}

- (IBAction)renderAdButtonAction:(id)sender {
    // Get the required custom template view. Please note, NativeAdCustomMediumTemplateView is created on app side.
    // For template type POBNativeTemplateTypeSmall, use POBNativeAdSmallTemplateView class.
    // For template type POBNativeTemplateTypeMedium, use POBNativeAdMediumTemplateView class.
    POBNativeAdMediumTemplateView *templateView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdCustomMediumTemplateView" owner:nil options:nil].firstObject;

    // Render the native ad with custom template view.
    __weak typeof(self) weakSelf = self;
    [self.nativeAd renderAdWithTemplateView:templateView andCompletion:^(id<POBNativeAd>  _Nonnull nativeAd, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [self log:@"Native : Failed to render ad with error - %@", [error localizedDescription]];
        } else {
            // Attach the native ad view.
            strongSelf.nativeAdView = [nativeAd adView];
            [strongSelf addNativeAdView];
            [self log:@"Native : Ad rendered."];
        }
    }];
}

#pragma mark - NativeAdLoaderDelegate

// Notifies the delegate that an ad has been successfully loaded.
- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didReceiveAd:(id<POBNativeAd>)nativeAd{
    self.nativeAd = nativeAd;
    [self.renderAdButton setEnabled:YES];

    // Set native ad delegate.
    [self.nativeAd setAdDelegate:self];
    [self log:@"Native : Ad received."];
}

// Notifies the delegate of an error encountered while loading an ad.
- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
    [self log:@"Native : Failed to receive ad with error - %@", [error localizedDescription]];
}

// Returns a view controller instance to be used by ad server SDK for showing modals.
- (UIViewController *)viewControllerForPresentingModal{
    return self;
}

#pragma mark - NativeAdDelegate

// Notifies delegate that the native ad has dismissed the modal on top of the current view controller.
- (void)nativeAdDidDismissModal:(POBNativeAdView *)adView{
    [self log:@"Native : Dismissed modal"];
}

// Notifies delegate that the native ad will launch a modal on top of the current view controller, as a result of user interaction.
- (void)nativeAdWillPresentModal:(POBNativeAdView *)adView{
    [self log:@"Native : Will present modal"];
}

// Notifies delegate that the native ad have launched a modal on top of the current view controller, as a result of user interaction.
- (void)nativeAdDidPresentModal:(POBNativeAdView *)adView {
    [self log:@"Native : Did present modal"];
}

// Notifies the delegate whenever current app goes in the background due to user click.
- (void)nativeAdWillLeaveApplication:(POBNativeAdView *)adView{
    [self log:@"Native : Will leave application"];
}

// Informs delegate that the native ad has recorded a click.
- (void)nativeAdDidRecordClick:(POBNativeAdView *)adView {
    [self log:@"Native : Ad click."];
}

// Informs delegate that the native ad has recorded a click for a particular asset.
- (void)nativeAd:(POBNativeAdView *)adView didRecordClickForAsset:(NSInteger)assetId {
    [self log:@"Native : Recorded click for asset with Id: %ld", assetId];
}

// Informs delegate that the native ad has recorded an impression.
- (void)nativeAdDidRecordImpression:(POBNativeAdView *)adView {
    [self log:@"Native : Recorded impression."];
}

#pragma mark - Supporting Methods

- (void)addNativeAdView{
    self.nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.nativeAdView];

    // Decide layout guide based on available iOS version
    UILayoutGuide *layoutGuide;
    if (@available(iOS 11.0, *)) {
        layoutGuide = self.view.safeAreaLayoutGuide;
    } else {
        layoutGuide = self.view.layoutMarginsGuide;
    }

    [NSLayoutConstraint activateConstraints:@[
        [self.nativeAdView.widthAnchor constraintEqualToConstant:self.nativeAdView.frame.size.width],
        [self.nativeAdView.heightAnchor constraintEqualToConstant:self.nativeAdView.frame.size.height],
        [self.nativeAdView.bottomAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor],
        [self.nativeAdView.centerXAnchor constraintEqualToAnchor:layoutGuide.centerXAnchor]
    ]];
}

- (void)closeNativeAd {
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    self.nativeAd = nil;
}

@end
