// This class is compatible with OpenWrap SDK v1.5.0 and MoPub SDK 5.10.0

#import "POBBannerCustomEvent.h"
#import <POBBid.h>

@implementation POBBannerCustomEvent

// Method required for MoPub SDK versions 5.9.0 and below
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    [self loadAdWithSize:size customEventInfo:info];
}

// Method required for MoPub SDK versions 5.10.0 and above
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup{
    [self loadAdWithSize:size customEventInfo:info];
}

#pragma mark - Supporting Methods

- (void)loadAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    if (self.localExtras == nil) {
        [self handleCustomEventFailure];
        return;
    }
    POBBid *bid = self.localExtras[@"pob_bid"];
    bid.hasWon = YES;
    //Removing POBBannerRenderer from this class, so removed the below method call from rendererDidRenderAd and added here to handle the refresh functionality for MoPub IBVideo.
    [self.delegate bannerCustomEvent:self didLoadAd:[UIView new]];
}

-(void)handleCustomEventFailure{
    NSError *error = [NSError errorWithDomain:kPOBErrorDomain code:POBErrorNoAds userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Bid not available for custom event", comment: @"Bid not available for custom event")}];
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

@end
