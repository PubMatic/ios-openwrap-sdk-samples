

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DummyAdServerDelegate <NSObject>
@optional
// called when a banner ad is loaded
- (void)didLoadBannerAd:(UIView *)bannerView;

// called when a interstitial ad is loaded
- (void)didReceiveInterstitialAd;

// called when the SDK fails to load an ad
- (void)didFailWithError:(NSError *)error;

// A dummy custom event triggered based on targeting information sent in the request.
- (void)didReceiveCustomEvent:(NSString*)event;

@end

@interface DummyAdServerSDK : NSObject

/*!
 @abstract Initializes & returns a newly allocated DummyAdServerSDK object.
 @param adUnit Ad unit id used to identify unique placement on screen.
 @result Instance of DummyAdServerSDK
 */
- (instancetype)initWithAdUnit:(NSString *)adUnit;

// Ad unit id of ad server SDK
@property(nonatomic, strong) NSString *adUnitId;

// Delegate to receive ad success/failure events.
@property(nonatomic, weak) id<DummyAdServerDelegate> delegate;

// loads a banner ad from the ad server
- (void)loadBannerAd;

// loads an interstitial ad from the ad server
- (void)loadInterstitailAd;

// Presents an interstitial ad
- (void)showInterstitialFromViewController:(UIViewController *)viewController;

// Sets custom targeting to be sent in the ad call
- (void)setCustomTargeting:(NSDictionary *)targeting;

@end
NS_ASSUME_NONNULL_END
