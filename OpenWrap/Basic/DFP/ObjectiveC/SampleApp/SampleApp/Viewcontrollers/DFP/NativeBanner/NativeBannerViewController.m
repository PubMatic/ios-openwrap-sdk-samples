/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2022 PubMatic, All Rights Reserved.
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

#import "NativeBannerViewController.h"
#import "CustomNativeAdView.h"
@import OpenWrapSDK;
@import OpenWrapHandlerDFP;
@import GoogleMobileAds;

#define GAM_AU        @"/15671365/pm_sdk/PMSDK-Demo-App-NativeAndBanner"
#define OW_ADUNIT_ID  @"/15671365/pm_sdk/PMSDK-Demo-App-NativeAndBanner"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

@interface NativeBannerViewController () <POBBannerViewDelegate, POBGAMNativeAdDelegate, POBGAMCustomNativeAdDelegate, GADNativeAdDelegate, GADCustomNativeAdDelegate>
/// OpenWrap banner view
@property (nonatomic) POBBannerView *bannerView;
/// The native or custom native ad view that is being presented.
@property(nonatomic, strong) UIView *nativeAdView;
@end

@implementation NativeBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *adSizes = @[ NSValueFromGADAdSize(kGADAdSizeMediumRectangle) ];
    
    // Create a native event handler for your ad server. Make
    // sure you use separate event handler objects to create each banner
    // For example, The code below creates an event handler for GAM ad server.
    GAMNativeEventHandler * eventHandler = [[GAMNativeEventHandler alloc] initWithAdUnitId:GAM_AU
                                                                                   adTypes:@[kGADAdLoaderAdTypeNative, kGADAdLoaderAdTypeCustomNative]
                                                                                   options:nil
                                                                                  andSizes:adSizes];
    // Set event handler delegate for native ad
    eventHandler.nativeDelegate = self;
    
    // Set event handler delegate for custom native ad
    eventHandler.customNativeDelegate = self;

    // Create a banner view
    // For test IDs refer - https://community.pubmatic.com/display/IDFP/Test+and+debug+your+integration
    self.bannerView = [[POBBannerView alloc]
                                 initWithPublisherId:PUB_ID
                                 profileId:PROFILE_ID
                                 adUnitId:OW_ADUNIT_ID
                                 eventHandler:eventHandler];
    // Set the delegate
    self.bannerView.delegate = self;

    // Load Ad
    [self.bannerView loadAd];
}

#pragma mark - Banner view delegate methods
// Provides a view controller to use for presenting model views
- (UIViewController *)bannerViewPresentationController {
    return self;
}

// Notifies the delegate that an ad has been successfully loaded and rendered.
- (void)bannerViewDidReceiveAd:(POBBannerView *)bannerView {
    NSLog(@"Banner : Ad received with size %@ ", bannerView.creativeSize);
    
    // Add the banner view to your view hierarchy.
    // You may also add it after an ad is successfully loaded.
    [self addBannerToView:self.bannerView withSize:bannerView.creativeSize.cgSize];
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)bannerView:(POBBannerView *)bannerView
didFailToReceiveAdWithError:(NSError *)error {
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

#pragma mark - OW GAM Native Ad event handler Delegate

// Notifies the delegate that an ad has been successfully received.
- (void)eventHandler:(id<POBBannerEvent>)eventHandler didReceiveNativeAd:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad received.");
    
    // Set GAM native ad delegate
    nativeAd.delegate = self;
    
    // Show native ad
    [self showNativeAdView:nativeAd];
}

#pragma mark - OW GAM Custom Native Ad event handler Delegate

// Return an array of custom native ad format ID
- (NSArray<NSString *> *)customNativeAdFormatIDs {
    return @[@"12051535"];
}

// Notifies the delegate that an ad has been successfully received.
- (void)eventHandler:(id<POBBannerEvent>)eventHandler didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
    NSLog(@"Custom Native : Ad received.");
    
    // Set GAM custom native ad delegate
    customNativeAd.delegate = self;
    
    // Show custom native ad
    [self showCustomNativeAdView:customNativeAd];
    
    // Record impression
    [customNativeAd recordImpression];
}

#pragma mark - GAM Native Ad Delegate

// Called when an impression is recorded for an ad. Only called for Google ads and is not
// supported for mediated ads.
- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad impression recorded.");
}

// Called when a click is recorded for an ad. Only called for Google ads and is not
// supported for mediated ads.
- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad click recorded.");
}

// Called before presenting the user a full screen view in response to an ad action
- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad will present screen.");
}

// Called before dismissing a full screen view.
- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad will dismiss screen.");
}

// Called after dismissing a full screen view
- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad did dismiss screen.");
}

// Used for Mute This Ad feature. Called after the native ad is muted.
- (void)nativeAdIsMuted:(GADNativeAd *)nativeAd {
    NSLog(@"Native : Ad is muted.");
}

#pragma mark - GAM Custom Native Ad Delegate

// Called when an impression is recorded for a custom native ad.
- (void)customNativeAdDidRecordImpression:(GADCustomNativeAd *)nativeAd {
    NSLog(@"Custom native : Ad recorded impression.");
}

// Called when a click is recorded for a custom native ad.
- (void)customNativeAdDidRecordClick:(GADCustomNativeAd *)nativeAd {
    NSLog(@"Custom native : Ad recorded click.");
}

// Called just before presenting the user a full screen view, such as a browser,
// in response to clicking on an ad.
- (void)customNativeAdWillPresentScreen:(GADCustomNativeAd *)nativeAd {
    NSLog(@"Custom native : Ad will present screen.");
}

// Called just before dismissing a full screen view.
- (void)customNativeAdWillDismissScreen:(GADCustomNativeAd *)nativeAd {
    NSLog(@"Custom native : Ad will dismiss screen.");
}

// Called just after dismissing a full screen view.
- (void)customNativeAdDidDismissScreen:(GADCustomNativeAd *)nativeAd {
    NSLog(@"Custom native : Ad did dismiss screen.");
}

#pragma mark - Native ad rendering helpers

// Show native ad
- (void)showNativeAdView:(GADNativeAd *)nativeAd {
    // Remove previous ad view.
    [self.nativeAdView removeFromSuperview];
    
    // Add new ad view and set constraints to fill its container.
    // Create and place ad in view hierarchy.
    GADNativeAdView *nativeAdView =
        [[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil].firstObject;
    self.nativeAdView = nativeAdView;
    [self addBannerToView:self.nativeAdView withSize:self.nativeAdView.frame.size];
        
    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
    nativeAdView.mediaView.hidden = nativeAd.mediaContent.mainImage ? NO : YES;

    // This app uses a fixed width for the GADMediaView and changes its height
    // to match the aspect ratio of the media content it displays.
    if (nativeAd.mediaContent.aspectRatio > 0) {
      NSLayoutConstraint *heightConstraint =
          [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:nativeAdView.mediaView
                                       attribute:NSLayoutAttributeWidth
                                      multiplier:(1 / nativeAd.mediaContent.aspectRatio)
                                        constant:0];
      heightConstraint.active = YES;
    }

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                                 forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;

    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;

    // Associate the native ad view with the native ad object. This is
    // required to make the ad clickable.
    // Note: this should always be done after populating the ad views.
    nativeAdView.nativeAd = nativeAd;
}

// Show custom native ad
- (void)showCustomNativeAdView:(GADCustomNativeAd *)customNativeAd {
    // Remove previous ad view.
    [self.nativeAdView removeFromSuperview];
    
    // Add new ad view and set constraints to fill its container.
    // Create and place ad in view hierarchy.
    CustomNativeAdView *customNativeAdView =
        [[NSBundle mainBundle] loadNibNamed:@"CustomNativeAdView" owner:nil options:nil].firstObject;
    [customNativeAdView populateCustomNativeAdView:customNativeAd];
    
    self.nativeAdView = customNativeAdView;
    [self addBannerToView:self.nativeAdView withSize:self.nativeAdView.frame.size];
}

// Attach banner view to superview
- (void)addBannerToView:(UIView *)bannerView withSize:(CGSize )size{
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    
    [bannerView.heightAnchor constraintEqualToConstant:size.height].active = YES;
    [bannerView.widthAnchor constraintEqualToConstant:size.width].active = YES;

    if (@available(iOS 11.0, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [bannerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
        [bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [bannerView.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor].active = YES;
        [bannerView.centerXAnchor constraintEqualToAnchor:margins.centerXAnchor].active = YES;
    }
}

// Gets an image representing the number of stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
    double starRating = numberOfStars.doubleValue;
    
    NSString *imageName = @"star_0";
    
    if (starRating >= 5) {
        imageName = @"star_5";
    } else if (starRating >= 4) {
        imageName = @"star_4";
    } else if (starRating >= 3) {
        imageName = @"star_3";
    } else if (starRating >= 2) {
        imageName = @"star_2";
    } else if (starRating >= 1) {
        imageName = @"star_1";
    }
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - dealloc

- (void)dealloc {
    _bannerView = nil;
    [_nativeAdView removeFromSuperview];
    _nativeAdView = nil;
}

@end
