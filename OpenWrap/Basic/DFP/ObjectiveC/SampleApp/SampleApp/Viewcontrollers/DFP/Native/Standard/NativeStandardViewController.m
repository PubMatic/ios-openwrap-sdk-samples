/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2024 PubMatic, All Rights Reserved.
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

#import "NativeStandardViewController.h"
#import "CustomNativeAdView.h"

#define GAM_AU          @"/15671365/pm_sdk/PMSDK-Demo-App-Native"
#define OW_ADUNIT_ID    @"/15671365/pm_sdk/PMSDK-Demo-App-Native"

#define OW_FORMAT_ID    @"12260425"
#define CUSTOM_FORMAT_ID @"12051535"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

@import OpenWrapSDK;
@import OpenWrapHandlerDFP;
@import GoogleMobileAds;

@interface NativeStandardViewController () <POBNativeAdLoaderDelegate, POBNativeAdDelegate>
@property (nonatomic, strong) POBNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) id<POBNativeAd> nativeAd;
@property (nonatomic, strong) POBNativeAdView *nativeAdView;
@end

@implementation NativeStandardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a native event handler for your ad server.
    // For example, The code below creates an event handler for GAM ad server.
    GAMNativeEventHandler *eventHandler = [[GAMNativeEventHandler alloc] initWithAdUnitId:GAM_AU adTypes:@[GADAdLoaderAdTypeNative, GADAdLoaderAdTypeCustomNative] options:nil owFormatId:OW_FORMAT_ID];
    
    // Populate your native ad view and return it in the given rendering block.
    __weak typeof(self) weakSelf = self;
    eventHandler.nativeRenderingBlock = ^GADNativeAdView * _Nullable(GADNativeAd * _Nonnull nativeAd) {
        __strong typeof(self) strongSelf = weakSelf;
        return [strongSelf preparedNativeAdView:nativeAd];
    };
    
    // Populate your custom native ad view and return it in the given rendering block.
    eventHandler.customNativeRenderingBlock = ^UIView * _Nullable(GADCustomNativeAd * _Nonnull customNativeAd) {
        __strong typeof(self) strongSelf = weakSelf;
        return [strongSelf preparedCustomNativeAdView:customNativeAd];
    };
    
    // This step is optional and you can set your custom format ids here.
    eventHandler.formatIds = @[CUSTOM_FORMAT_ID];
    
    // Create the Native Ad Loader with desired template type (in this case, small).
    // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-1#test-profileplacements
    self.nativeAdLoader = [[POBNativeAdLoader alloc] initWithPublisherId:PUB_ID profileId:PROFILE_ID adUnitId:OW_ADUNIT_ID templateType:POBNativeTemplateTypeSmall eventHandler:eventHandler];
    
    // Set the delegate.
    self.nativeAdLoader.delegate = self;
    
    // Load ad.
    [self.nativeAdLoader loadAd];
}

- (void)dealloc{
    _nativeAdView = nil;
    _nativeAd = nil;
    _nativeAdLoader = nil;
}

#pragma mark - NativeAdLoaderDelegate

// Notifies the delegate that an ad has been successfully loaded.
- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didReceiveAd:(id<POBNativeAd>)nativeAd{
    NSLog(@"Native : Ad received.");
    self.nativeAd = nativeAd;
    // Set native ad delegate.
    [self.nativeAd setAdDelegate:self];
    
    // Render the native ad.
    __weak typeof(self) weakSelf = self;
    [self.nativeAd renderAdWithCompletion:^(id<POBNativeAd> nativeAd, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error){
            NSLog(@"Native : Failed to render ad with error - %@", [error localizedDescription]);
        }else{
            // Attach the native ad view.
            strongSelf.nativeAdView = [nativeAd adView];
            [strongSelf addNativeAdView];
            NSLog(@"Native : Ad rendered.");
        }
    }];
}

// Notifies the delegate of an error encountered while loading an ad.
- (void)nativeAdLoader:(POBNativeAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Native : Failed to receive ad with error - %@", [error localizedDescription]);
}

// Returns a view controller instance to be used by ad server SDK for showing modals.
- (UIViewController *)viewControllerForPresentingModal{
    return self;
}

#pragma mark - NativeAdDelegate

// Notifies delegate that the native ad has dismissed the modal on top of the current view controller.
- (void)nativeAdDidDismissModal:(POBNativeAdView *)adView{
    NSLog(@"Native : Dismissed modal");
}

// Notifies delegate that the native ad will launch a modal on top of the current view controller, as a result of user interaction.
- (void)nativeAdWillPresentModal:(POBNativeAdView *)adView{
    NSLog(@"Native : Will present modal");
}

// Notifies delegate that the native ad have launched a modal on top of the current view controller, as a result of user interaction.
- (void)nativeAdDidPresentModal:(POBNativeAdView *)adView {
    NSLog(@"Native : Did present modal");
}

// Notifies the delegate whenever current app goes in the background due to user click.
- (void)nativeAdWillLeaveApplication:(POBNativeAdView *)adView{
    NSLog(@"Native : Will leave application");
}

// Informs delegate that the native ad has recorded a click.
- (void)nativeAdDidRecordClick:(POBNativeAdView *)adView {
    NSLog(@"Native : Ad click.");
}

// Informs delegate that the native ad has recorded a click for a particular asset.
- (void)nativeAd:(POBNativeAdView *)adView didRecordClickForAsset:(NSInteger)assetId {
    NSLog(@"Native : Recorded click for asset with Id: %ld", assetId);
}

// Informs delegate that the native ad has recorded an impression.
- (void)nativeAdDidRecordImpression:(POBNativeAdView *)adView {
    NSLog(@"Native : Recorded impression.");
}

#pragma mark - Supporting Methods

- (GADNativeAdView *)preparedNativeAdView:(GADNativeAd*)nativeAd {
    // Create and place ad in view hierarchy.
    GADNativeAdView *nativeAdView =
        [[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil].firstObject;
    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

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
    return nativeAdView;
}

- (CustomNativeAdView*)preparedCustomNativeAdView:(GADCustomNativeAd*)customNativeAd {
    //render custom native ad
    CustomNativeAdView *customNativeAdView =
        [[NSBundle mainBundle] loadNibNamed:@"CustomNativeAdView" owner:nil options:nil]
            .firstObject;
    // Populate the custom native ad view with its assets.
    [customNativeAdView populateCustomNativeAdView:customNativeAd];
    
    return customNativeAdView;
}

- (void)addNativeAdView{
    CGSize size = self.nativeAdView.frame.size;
    self.nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.nativeAdView];
    
    [self.nativeAdView.heightAnchor constraintEqualToConstant:size.height].active = YES;
    [self.nativeAdView.widthAnchor constraintEqualToConstant:size.width].active = YES;

    if (@available(iOS 11.0, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [self.nativeAdView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
        [self.nativeAdView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [self.nativeAdView.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor].active = YES;
        [self.nativeAdView.centerXAnchor constraintEqualToAnchor:margins.centerXAnchor].active = YES;
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

@end
