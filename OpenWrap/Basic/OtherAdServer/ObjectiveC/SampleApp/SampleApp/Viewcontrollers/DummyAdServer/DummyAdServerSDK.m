
#import "DummyAdServerSDK.h"

static NSString *const CUSTOM_EVENT = @"SomeCustomEvent";

// Emulates an Ad Server SDK
@implementation DummyAdServerSDK

- (instancetype)initWithAdUnit:(NSString *)adUnit {
    self = [super init];
    if (self) {
        _adUnitId = adUnit;
    }
    return self;
}

- (void)loadBannerAd {
    // Usually, the ad server determines whether the partner bid won in the
    // auction, based on provided targeting information. Then, the ad server SDK
    // will either render the banner ad or indicate that a partner ad should be
    // rendered.
    if ([_adUnitId isEqualToString:@"OtherASBannerAdUnit"]) {
        [self.delegate didReceiveCustomEvent:CUSTOM_EVENT];
    }else{
        [self.delegate didLoadBannerAd:[UIView new]];
    }
}

- (void)loadInterstitailAd {
    // Usually, the ad server determines whether the partner bid won in the
    // auction, based on provided targeting information. Then, the ad server SDK
    // will either load the interstitial ad or indicate that a partner ad should
    // be rendered.
    if ([_adUnitId isEqualToString:@"OtherASInterstitialAdUnit"]) {
        [self.delegate didReceiveCustomEvent:CUSTOM_EVENT];
    }else{
        [self.delegate didReceiveInterstitialAd];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    // This implementation of your ad server SDK's interstitial ad presents an
    // interstitial ad
}

- (void)setCustomTargeting:(NSDictionary *)targeting{
    // Sets custom targeting to be sent in the ad call
}

@end
