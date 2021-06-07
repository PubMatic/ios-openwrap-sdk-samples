//This class is compatible with OpenWrap SDK v1.5.0

@import OpenWrapSDK;

/*!
 This class is responsible for communication between OpenWrap interstitial and interstitial ad from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenWrap SDK using POBInterstitialEventDelegate methods
 */
@interface CustomInterstitialEventHandler : NSObject <POBInterstitialEvent>
-(instancetype)initWithAdUnit:(NSString*)adUnit;

@end
