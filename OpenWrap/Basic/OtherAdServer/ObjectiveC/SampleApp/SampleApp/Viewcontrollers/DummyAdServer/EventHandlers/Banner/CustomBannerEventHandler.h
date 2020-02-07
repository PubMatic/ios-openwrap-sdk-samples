//This class is compatible with OpenWrap SDK v1.5.0

#import <POBBannerEvent.h>

/*!
 This class is responsible for communication between OpenWrap banner view and banner view from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBBannerEvent protocol. it notifies event back to OpenWrap SDK using POBBannerEventDelegate methods
 */
@interface CustomBannerEventHandler : NSObject <POBBannerEvent>
-(instancetype)initWithAdUnit:(NSString*)adUnit sizes:(NSArray*)adSizes;

@end
