

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <POBInterstitialEvent.h>

/*!
 DFP interstitial configuration block having DFPInterstitial, request as parameters
 */
typedef void(^DFPInterstitialConfigBlock)(DFPInterstitial *interstitial,DFPRequest * request);

/*!
 This class is responsible for communication between OpenBid interstitial and DFP interstitial .
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenBid SDK using POBInterstitialEventDelegate methods
 */
@interface DFPInterstitialEventHandler : NSObject <POBInterstitialEvent>

/*!
 Initializes and returns a event handler with the specified DFP ad unit
 @param adUnitId DFP ad unit id
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/*!
 A configBlock that is called before event handler makes ad request call to DFP SDK. It passes DFPInterstitial & DFPRequest which will be used to make ad request.
 */
@property (nonatomic, copy) DFPInterstitialConfigBlock configBlock;
@end
