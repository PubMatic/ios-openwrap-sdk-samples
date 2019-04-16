

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <POBBannerEvent.h>

/*!
 DFP banner configuration block having DFPBannerView, request as parameters
 */
typedef void(^DFPBannerConfigBlock)(DFPBannerView *view,DFPRequest * request);

/*!
 This class is responsible for communication between OpenBid banner view and DFP banner view.
 It implements the POBBannerEvent protocol. it notifies event back to OpenBid SDK using POBBannerEventDelegate methods
 */
@interface DFPBannerEventHandler : NSObject <POBBannerEvent>

/*!
 Initializes and returns a event handler with the specified DFP ad unit and ad sizes
 
 @param adUnitId DFP ad unit id
 @param validSizes Array of NSValue encoded GADAdSize structs. Never create your own GADAdSize directly. Use one of the predefined
 standard ad sizes (such as kGADAdSizeBanner), or create one using the GADAdSizeFromCGSize
 method.
 Example:
 <pre>
 NSArray *validSizes = @[
 NSValueFromGADAdSize(kGADAdSizeBanner),
 NSValueFromGADAdSize(kGADAdSizeLargeBanner)
 ];
 bannerView.validAdSizes = validSizes;
 </pre>

 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                    andSizes:(NSArray *)validSizes;

/*!
 A configBlock that is called before event handler makes ad request call to DFP SDK. It passes DFPBannerView & DFPRequest which will be used to make ad request.
 */
@property (nonatomic, copy) DFPBannerConfigBlock configBlock;
@end
