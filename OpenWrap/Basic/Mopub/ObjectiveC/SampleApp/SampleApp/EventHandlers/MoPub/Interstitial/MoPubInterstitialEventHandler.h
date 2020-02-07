// This class is compatible with OpenWrap SDK v1.5.0 and MoPub SDK 5.10.0

#import <Foundation/Foundation.h>
#import <POBInterstitialEvent.h>
#import <MPInterstitialAdController.h>

/*!
 Mopub interstitial configuration block having MPInterstitialAdController as parameter
 */
typedef void(^MPInterstitialConfigBlock)(MPInterstitialAdController *interstitial);

/*!
 This class is responsible for communication between OpenWrap interstitial and Mopub interstitial controller.
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenWrap SDK using POBInterstitialEventDelegate methods
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
