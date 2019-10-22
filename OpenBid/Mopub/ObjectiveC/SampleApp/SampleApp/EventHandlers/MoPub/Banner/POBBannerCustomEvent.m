

#import "POBBannerCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBBannerCustomEvent()<POBAdRendererDelegate>
@property (nonatomic, strong) id<POBBannerRendering> bannerRenderer;
@end

@implementation POBBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info{
    if (self.localExtras == nil) {
        [self handleCustomEventFailure];
        return;
    }
    POBBid *bid = self.localExtras[@"pob_bid"];
    _bannerRenderer = [POBRenderer bannerRenderer];
    [_bannerRenderer setDelegate:self];
    [_bannerRenderer renderAdDescriptor:bid];
}

-(void)handleCustomEventFailure{
    NSError *error = [NSError errorWithDomain:kPOBErrorDomain code:POBErrorNoAds userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Bid not available for custom event", comment: @"Bid not available for custom event")}];
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark - PMAdRendererDelegate
- (void)rendererDidRenderAd:(id)renderedAd forDescriptor:(id<POBAdDescriptor>)ad {
    UIView *rendererView = renderedAd;
    POBBid *bid = self.localExtras[@"pob_bid"];
    rendererView.frame = CGRectMake(0, 0, bid.size.width, bid.size.height);
    [self.delegate bannerCustomEvent:self didLoadAd:renderedAd];
}

- (void)rendererDidFailToRenderAdWithError:(NSError *)error forDescriptor:(id<POBAdDescriptor>)ad {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)rendererWillPresentModal {
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)rendererDidDismissModal {
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)rendererWillLeaveApp {
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (UIViewController *)viewControllerForPresentingModal {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)dealloc {
    _bannerRenderer = nil;
}

@end
