

#import <Foundation/Foundation.h>
#import <POBInterstitialEvent.h>
#import <MPInterstitialAdController.h>

/*!
 Mopub interstitial configuration block having MPInterstitialAdController as parameter
 */
typedef void(^MPInterstitialConfigBlock)(MPInterstitialAdController *interstitial);

/*!
 This class is responsible for communication between OpenBid interstitial and Mopub interstitial controller.
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenBid SDK using POBInterstitialEventDelegate methods
 */
@interface MoPubInterstitialEventHandler : NSObject <POBInterstitialEvent>

/*!
 Initializes and returns a event handler with the specified Mopub ad unit
 
 @param adUnitId Mopub ad unit id
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

/*!
 A configBlock that is called before event handler makes ad request call to Mopub SDK. It passes MPInterstitialAdController which will be used to make ad request.
 */
@property (nonatomic, copy) MPInterstitialConfigBlock configBlock;

@end
