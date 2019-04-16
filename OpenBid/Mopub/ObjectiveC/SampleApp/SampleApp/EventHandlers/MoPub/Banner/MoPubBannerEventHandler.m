

#import "MoPubBannerEventHandler.h"

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
        
        _adSize = size;
        // Do any additional setup required for MoPub Banner Ads
        // Create a MoPub Banner
        self.bannerView = [[MPAdView alloc] initWithAdUnitId:adUnitId
                                                        size:size];
        
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

    if (_bannerView.delegate != self) {
        NSLog(@"Do not set Mopub delegate. It is used by MoPubBannerEventHandler internally.");
    }

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

- (void)adViewDidLoadAd:(MPAdView *)view{
    _adContentSize = view.adContentViewSize;
    [self.delegate adServerDidWin:view];
}

-(void)adViewDidFailToLoadAd:(MPAdView *)view{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"MoPub ad server failed to load ad", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"MoPub ad server failed to load ad", nil)
                               };
    NSError *eventError = [NSError errorWithDomain:kPOBErrorDomain
                                              code:POBErrorNoAds
                                          userInfo:userInfo];
    [_delegate failedWithError:eventError];
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
#pragma mark -

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
