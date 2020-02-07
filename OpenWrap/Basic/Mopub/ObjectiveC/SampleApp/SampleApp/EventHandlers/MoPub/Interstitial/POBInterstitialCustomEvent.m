// This class is compatible with OpenWrap SDK v1.5.0 and MoPub SDK 5.10.0

#import "POBInterstitialCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBInterstitialCustomEvent () <POBInterstitialRendererDelegate>
@property (nonatomic, strong) id<POBInterstitialRendering> currentRenderer;
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation POBInterstitialCustomEvent

// Method required for MoPub SDK versions 5.9.0 and below
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    [self loadAdWithCustomEventInfo:info];
}

// Method required for MoPub SDK versions 5.10.0 and above
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    [self loadAdWithCustomEventInfo:info];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    self.viewController = rootViewController;
    NSDictionary *customData = self.localExtras[@"customData"];
    NSNumber *loadTimeOrientation = customData[@"loadTimeOrientation"];
    [_currentRenderer showFromViewController:_viewController
                               inOrientation:loadTimeOrientation.integerValue];
}

#pragma mark - Supporting Methods

- (void)loadAdWithCustomEventInfo:(NSDictionary *)info {
    if (self.localExtras == nil) {
        [self handleCustomEventFailure];
        return;
    }
    POBBid *bid = self.localExtras[@"pob_bid"];
    bid.hasWon = YES;
    _currentRenderer = [POBRenderer interstitialRenderer];
    [_currentRenderer setDelegate:self];
    [_currentRenderer renderAdDescriptor:bid];
}

-(void)handleCustomEventFailure{
    NSError *error = [NSError errorWithDomain:kPOBErrorDomain code:POBErrorNoAds userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Bid not available for custom event", comment: @"Bid not available for custom event")}];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark - PMInterstitialRendererDelegate

- (void)interstitialRendererDidRenderAd {
    [self.delegate interstitialCustomEvent:self didLoadAd:[UIView new]];
}

- (void)interstitialRendererDidFailToRenderAdWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialRendererDidClick {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialRendererWillLeaveApp {
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)interstitialRendererWillPresentModal {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialRendererDidDismissModal {
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialRendererDidExpireAd {
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (UIViewController *)viewControllerForPresentingModal {
    return _viewController;
}

- (void)dealloc {
    _currentRenderer = nil;
}

@end
