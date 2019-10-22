


#import "POBInterstitialCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBInterstitialCustomEvent () <POBInterstitialRendererDelegate>
@property (nonatomic, strong) id<POBInterstitialRendering> currentRenderer;
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation POBInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{
    if (self.localExtras == nil) {
        [self handleCustomEventFailure];
        return;
    }
    POBBid *bid = self.localExtras[@"pob_bid"];
    _currentRenderer = [POBRenderer interstitialRenderer];
    [_currentRenderer setDelegate:self];
    [_currentRenderer renderAdDescriptor:bid];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    self.viewController = rootViewController;
    NSDictionary *customData = self.localExtras[@"customData"];
    NSNumber *loadTimeOrientation = customData[@"loadTimeOrientation"];
    [_currentRenderer showFromViewController:_viewController
                               inOrientation:loadTimeOrientation.integerValue];
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

- (UIViewController *)viewControllerForPresentingModal {
    return _viewController;
}

- (void)dealloc {
    _currentRenderer = nil;
}

@end
