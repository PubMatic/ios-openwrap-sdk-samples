//This class is compatible with OpenWrap SDK v1.5.0

#import "CustomBannerEventHandler.h"
#import "DummyAdServerSDK.h"

@interface CustomBannerEventHandler ()<DummyAdServerDelegate>
@property(nonatomic, weak) id<POBBannerEventDelegate> delegate;
@property(nonatomic, strong) DummyAdServerSDK *adServerSDK;
@property (nonatomic, strong) NSArray *adSizes;
@end

@implementation CustomBannerEventHandler

-(instancetype)initWithAdUnit:(NSString*)adUnit sizes:(NSArray*)adSizes{
    self = [super init];
    if (self) {
        _adSizes = adSizes;
        _adServerSDK = [[DummyAdServerSDK alloc] initWithAdUnit:adUnit];
        _adServerSDK.delegate = self;
    }
    return self;
}

#pragma mark - POBBannerEvent methods
- (void)setDelegate:(id<POBBannerEventDelegate>)delegate {
    _delegate = delegate;
}

// OpenWrap SDK passes its bids through this method. You should request an ad from your ad server here.
- (void)requestAdWithBid:(POBBid *)bid {
    // If bid is valid, add bid related custom targeting on the ad request
    if (bid) {
        [_adServerSDK setCustomTargeting:bid.targetingInfo];
        NSLog(@"Custom targeting : %@", bid.targetingInfo);
    }
    
    // Load ad from the ad server
    [_adServerSDK loadBannerAd];
}

//return the content size of the ad received from the ad server
- (CGSize)adContentSize {
    return CGSizeMake(320, 50);
}

// return requested ad sizes for the bid request
- (NSArray<POBAdSize *> *)requestedAdSizes {
    NSMutableArray *sizes = [[NSMutableArray alloc] initWithCapacity:self.adSizes.count];
    for (NSValue *value in self.adSizes) {
        [sizes addObject:POBAdSizeMakeFromCGSize(value.CGSizeValue)];
    }
    
    return sizes;
}

#pragma mark - DummyAdServerDelegate methods
// A dummy custom event triggered based on targeting information sent in the request.
// This sample uses this event to determine if the partner ad should be served.
- (void)didReceiveCustomEvent:(NSString *)event{
    // Identify if the ad from OpenWrap partner is to be served and, if so, call 'openWrapPartnerDidWin'
    if ([event isEqualToString:@"SomeCustomEvent"]) {
        // partner ad should be served
        [self.delegate openWrapPartnerDidWin];
    }
}

// Called when the banner ad is loaded from ad server.
-(void)didLoadBannerAd:(UIView *)bannerView
{
    [self.delegate adServerDidWin:bannerView];
}

// Tells the delegate that an ad request failed. The failure is normally due to
// network connectivity or ad availability (i.e., no fill).
- (void)didFailWithError:(NSError *)error{
    [_delegate failedWithError:error];
}

//Similarly you can implement all the other ad flow events

@end
