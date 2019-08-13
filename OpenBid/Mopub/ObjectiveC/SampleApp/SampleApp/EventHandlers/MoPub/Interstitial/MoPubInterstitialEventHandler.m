

#import "MoPubInterstitialEventHandler.h"
#import <MPError.h>

@interface MoPubInterstitialEventHandler() <MPInterstitialAdControllerDelegate>

@property (nonatomic, strong)   MPInterstitialAdController *interstitial;
@property (nonatomic, weak)     id<POBInterstitialEventDelegate> delegate;
@property (nonatomic, copy)     NSString *adUnitId;

@end


@implementation MoPubInterstitialEventHandler

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    
    self = [super init];
    if (self) {
        _adUnitId = adUnitId;
        
        // Initialize MPInterstitialAdController
        _interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:_adUnitId];
        
        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        _interstitial.delegate = self;
    }
    return self;
}

- (void)dealloc {
    _interstitial.delegate = nil;
    _interstitial = nil;
    _delegate = nil;
    _configBlock = nil;
}

#pragma mark - POBInterstitialEvent

- (void)requestAdWithBid:(POBBid *)bid {
    
    _interstitial.keywords = nil;
    if (_interstitial.delegate != self) {
        NSLog(@"Do not set Mopub delegate. It is used by MoPubInterstitialEventHandler internally.");
    }

    // If bid is valid, add bid related keywords on Mopub view
    if (bid) {
        if (self.configBlock) {
            self.configBlock(self.interstitial);
        }
        NSString * keywords = [self keywordsForBid:bid];
        self.interstitial.keywords = keywords;
        NSLog(@"MoPub interstitial keywords: %@", keywords);

        NSMutableDictionary *localExtras = [NSMutableDictionary dictionaryWithDictionary:self.interstitial.localExtras];
        if (bid.status.boolValue) {
            localExtras[@"pob_bid"] = bid;
        }
        localExtras[@"customData"] = [self.delegate customData];
        self.interstitial.localExtras = localExtras;
    }

    [self.interstitial loadAd];
}

- (void)setDelegate:(id<POBInterstitialEventDelegate>) delegate {
    _delegate = delegate;
}

- (void)showFromViewController:(UIViewController *)controller {
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:controller];
    } else {
        NSLog(@"Interstitial ad is not ready to show.");
    }
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self.delegate adServerDidWin];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    
    NSString *failureMsg = @"MoPub ad server failed to load ad";
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(failureMsg, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(failureMsg, nil)
                               };
    NSError *eventError = [NSError errorWithDomain:kPOBErrorDomain
                                              code:POBErrorNoAds
                                          userInfo:userInfo];
    [self.delegate failedWithError:eventError];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
                          withError:(NSError *)error {

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

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    [self.delegate willPresentAd];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    [self.delegate didDismissAd];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    [self.delegate didClickAd];
}

#pragma mark - Private methods

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
    if (self.interstitial.keywords.length) {
        [keywords appendFormat:@"%@,", self.interstitial.keywords];
    }
    if (keywords.length) {
        [keywords deleteCharactersInRange:NSMakeRange(keywords.length-1, 1)];
    }
    return [NSString stringWithString:keywords];
}

@end
