

#import <POBBannerEvent.h>

/*!
 This class is responsible for communication between OpenBid banner view and banner view from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBBannerEvent protocol. it notifies event back to OpenBid SDK using POBBannerEventDelegate methods
 */
@interface CustomBannerEventHandler : NSObject <POBBannerEvent>
-(instancetype)initWithAdUnit:(NSString*)adUnit;

@end
