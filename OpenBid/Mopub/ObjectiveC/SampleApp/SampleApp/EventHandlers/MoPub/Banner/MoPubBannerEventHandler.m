

#import "MoPubBannerEventHandler.h"
#import <MPError.h>

@interface MoPubBannerEventHandler()<MPAdViewDelegate>
@property (nonatomic, strong) MPAdView *bannerView;
@property (nonatomic, weak) id<POBBannerEventDelegate> delegate;
@property (nonatomic, assign) CGSize adContentSize;
@property (nonatomic, assign) CGSize adSize;
@end

@implementation MoPubBannerEventHandler

-(instancetype)initWithAdUnitId:(NSString *)adUnitId adSize:(CGSize)size{
    self = [super init];
    if (self) {
        
        // Do any additional setup required for MoPub Banner Ads
        // Create a MoPub Banner
        self.bannerView = [[MPAdView alloc] initWithAdUnitId:adUnitId];
        self.bannerView.maxAdSize = size;
        self.adSize = self.bannerView.adContentViewSize;
        
        // Set banner view frame
        CGRect frame = self.bannerView.frame;
        frame.size = self.adSize;
        self.bannerView.frame = frame;
        
        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        self.bannerView.delegate = self;
        
        // Disable MPAdView refresh, refresh will be managed by OpenBid SDK.
        [self.bannerView stopAutomaticallyRefreshingContents];
    }
    return self;
}

-(void)dealloc{
    _bannerView.delegate = nil;
    _bannerView = nil;
    _delegate = nil;
}

#pragma mark - POBBannerEvent delegates
- (CGSize)adContentSize {
    return _adContentSize;
}

- (void)requestAdWithBid:(POBBid *)bid {
    
    _bannerView.keywords = nil;

    // If bid is valid, add bid related keywords on Mopub view
    if (bid) {
        if (self.configBlock) {
            self.configBlock(self.bannerView);
        }
        NSString * keywords = [self keywordsForBid:bid];
        self.bannerView.keywords = keywords;
        NSLog(@"MoPub banner keywords: %@", keywords);

        if (bid.status.boolValue) {
            NSMutableDictionary *localExtras = [NSMutableDictionary dictionaryWithDictionary:self.bannerView.localExtras];
             localExtras[@"pob_bid"] = bid;
            self.bannerView.localExtras = localExtras;
        }
    }
    // NOTE: Please do not remove this code. Need to reset MoPub banner delegate to MoPubBannerEventHandler as these are used by MoPubBannerEventHandler internally. Changing the mopub delegate to other instance may break the callbacks and the banner refresh mechanism.
    if (self.bannerView.delegate != self) {
        NSLog(@"Resetting MoPub banner delegate to MoPubBannerEventHandler as these are used by MoPubBannerEventHandler internally.");
        self.bannerView.delegate = self;
    }
    [self.bannerView loadAd];
}

- (NSArray<POBAdSize *> *)requestedAdSizes{
    POBAdSize *size = POBAdSizeMakeFromCGSize(self.adSize);
    return @[size];
}

- (void)setDelegate:(id<POBBannerEventDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - MPAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModal];
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    _adContentSize = adSize;
    [self.delegate adServerDidWin:view];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSError *eventError = nil;
    switch (error.code) {
        case MOPUBErrorNoNetworkData:
        case MOPUBErrorNoInventory:
        case MOPUBErrorAdapterHasNoInventory:
            // No data found in NSHTTPURL response
            eventError = [self eventError:error withErrorCode:POBErrorNoAds];
            break;
            
        case MOPUBErrorNetworkTimedOut:
            eventError = [self eventError:error withErrorCode:POBErrorNetworkError];
            break;
            
        case MOPUBErrorServerError:
            eventError = [self eventError:error withErrorCode:POBErrorServerError];
            break;
            
        case MOPUBErrorAdRequestTimedOut:
            eventError = [self eventError:error withErrorCode:POBErrorTimeout];
            break;
            
        case MOPUBErrorAdapterInvalid:
        case MOPUBErrorAdapterNotFound:
            eventError = [self eventError:error withErrorCode:POBSignalingError];
            break;
            
        case MOPUBErrorAdUnitWarmingUp:
        case MOPUBErrorSDKNotInitialized:
            eventError = [self eventError:error withErrorCode:POBErrorInternalError];
            break;
            
        case MOPUBErrorUnableToParseJSONAdResponse:
        case MOPUBErrorUnexpectedNetworkResponse:
            eventError = [self eventError:error withErrorCode:POBErrorInvalidResponse];
            break;
            
        case MOPUBErrorNoRenderer:
            eventError = [self eventError:error withErrorCode:POBErrorRenderError];
            break;
            
        default:
            eventError = error;
            break;
    }
    
    [self.delegate failedWithError:eventError];
}

-(void)willPresentModalViewForAd:(MPAdView *)view{
    [self.delegate willPresentModal];
}

-(void)didDismissModalViewForAd:(MPAdView *)view{
    [self.delegate didDismissModal];
}

-(void)willLeaveApplicationFromAd:(MPAdView *)view{
    [self.delegate willLeaveApp];
}

#pragma mark - Private Methods

-(NSError *)eventError:(NSError *)error  withErrorCode:(POBErrorCode )code{
    NSError *eventError = [NSError errorWithDomain:kPOBErrorDomain
                                              code:code
                                          userInfo:error.userInfo];
    return eventError;
}

-(NSString *)keywordsForBid:(POBBid *)bid{
    NSMutableString *keywords = [NSMutableString new];
    NSDictionary *targetingInfo = bid.targetingInfo;
    for (NSString *key in targetingInfo) {
        [keywords appendFormat:@"%@:%@,", key, targetingInfo[key]];
    }
    if (self.bannerView.keywords.length) {
        [keywords appendFormat:@"%@,", self.bannerView.keywords];
    }
    if (keywords.length) {
        [keywords deleteCharactersInRange:NSMakeRange(keywords.length-1, 1)];
    }
    return [NSString stringWithString:keywords];
}

@end
