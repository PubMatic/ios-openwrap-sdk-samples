//This class is compatible with OpenWrap SDK v1.5.0

#import "CustomInterstitialEventHandler.h"
#import "DummyAdServerSDK.h"

@interface CustomInterstitialEventHandler () <DummyAdServerDelegate>
@property (nonatomic, weak) id<POBInterstitialEventDelegate> delegate;
@property(nonatomic, strong) DummyAdServerSDK *adServerSDK;
@end

@implementation CustomInterstitialEventHandler
-(instancetype)initWithAdUnit:(NSString*)adUnit{
    self = [super init];
    if (self) {
        _adServerSDK = [[DummyAdServerSDK alloc] initWithAdUnit:adUnit];
        _adServerSDK.delegate = self;
    }
    return self;
}

#pragma mark - POBInterstitialEvent methods

- (void)setDelegate:(id<POBInterstitialEventDelegate>)delegate {
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
    [_adServerSDK loadInterstitailAd];
}

// Called when interstitial is about to show
-(void)showFromViewController:(UIViewController *)controller{
    // Show ad using ad server SDK
    [_adServerSDK showInterstitialFromViewController:controller];
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

// Called when the interstitial ad is received.
-(void)didReceiveInterstitialAd{
    [self.delegate adServerDidWin];
}

// Tells the delegate that an ad request failed. The failure is normally due to
// network connectivity or ad availability (i.e., no fill).
- (void)didFailWithError:(NSError *)error{
    [_delegate failedWithError:error];
}

//Similarly you can implement all the other ad flow events

@end
