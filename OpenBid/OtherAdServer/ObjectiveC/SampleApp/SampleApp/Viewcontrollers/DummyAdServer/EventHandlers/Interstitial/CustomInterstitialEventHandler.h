

#import <POBInterstitialEvent.h>

/*!
 This class is responsible for communication between OpenBid interstitial and interstitial ad from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenBid SDK using POBInterstitialEventDelegate methods
 */
@interface CustomInterstitialEventHandler : NSObject <POBInterstitialEvent>
-(instancetype)initWithAdUnit:(NSString*)adUnit;

@end
