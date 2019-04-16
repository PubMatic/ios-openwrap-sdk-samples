

#import <Foundation/Foundation.h>
#import <POBBannerEvent.h>
#import <MPAdView.h>

/*!
 Mopub banner configuration block having MPAdView as parameter
 */
typedef void(^MPBannerConfigBlock)(MPAdView *view);

/*!
 This class is responsible for communication between OpenBid banner view and Mopub banner view.
 It implements the POBBannerEvent protocol. it notifies event back to OpenBid SDK using POBBannerEventDelegate methods
 */
@interface MoPubBannerEventHandler : NSObject<POBBannerEvent>

/*!
 Initializes and returns a event handler with the specified Mopub ad unit and ad sizes
 
 @param adUnitId Mopub ad unit id
 @param size ad size
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitId adSize:(CGSize)size;

/*!
 A configBlock that is called before event handler makes ad request call to Mopub SDK. It passes MPAdView which will be used to make ad request.
 */
@property (nonatomic, copy) MPBannerConfigBlock configBlock;
@end
