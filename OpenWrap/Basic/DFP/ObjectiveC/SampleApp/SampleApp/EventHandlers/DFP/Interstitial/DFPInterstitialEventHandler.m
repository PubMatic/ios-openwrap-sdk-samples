//This class is compatible with OpenWrap SDK v1.5.0

#import "DFPInterstitialEventHandler.h"

#define SYNC_TIMEOUT_INTEREVAL 0.8

@interface DFPInterstitialEventHandler () <
GADAppEventDelegate,
GADInterstitialDelegate>
@property(nonatomic, strong) DFPInterstitial *interstitial;
@property (nonatomic, weak) id<POBInterstitialEventDelegate> delegate;
@property (nonatomic, copy) NSString *adUnitId;
@property(nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL notified;
@property(nonatomic, assign) BOOL isAppEventExpected;
@end

@implementation DFPInterstitialEventHandler
- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    
    self = [super init];
    if (self) {
        _adUnitId = adUnitId;
    }
    return self;
}

- (void)dealloc {
    _interstitial.delegate = nil;
    _interstitial = nil;
    _configBlock = nil;
}

#pragma mark - POBInterstitialEvent methods

- (void)setDelegate:(id<POBInterstitialEventDelegate>)delegate {
    _delegate = delegate;
}

- (void)requestAdWithBid:(POBBid *)bid {
    
    _notified = NO;
    _isAppEventExpected = NO;
    
    // Create DFPInterstitial and set ad unit
    _interstitial = [[DFPInterstitial alloc]
                     initWithAdUnitID:self.adUnitId];
    
    // Set delegates on DFPInterstitial instance, these should not be removed/overridden else event handler will not work as expected.
    _interstitial.delegate = self;
    _interstitial.appEventDelegate = self;

    // Create DFP ad request
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];
    
    // Call configuration block if set. it can be used to configure DFP banner and ad request
    if (self.configBlock) {
        self.configBlock(_interstitial, dfpRequest);
    }
    
    if (!(_interstitial.appEventDelegate == self ||
          _interstitial.delegate == self)) {
        NSLog(@"Do not set DFP delegates. These are used by DFPInterstitialEventHandler internally.");
    }

    // If bid is valid, add bid related custom targetting on DFP ad request
    if (bid) {
        if (bid.status.boolValue) {
            _isAppEventExpected = YES;
        }
        NSMutableDictionary * customTargeting = [NSMutableDictionary dictionaryWithDictionary:dfpRequest.customTargeting];
        [customTargeting addEntriesFromDictionary:[bid targetingInfo]];
        [dfpRequest setCustomTargeting:[NSDictionary dictionaryWithDictionary:customTargeting]];
        NSLog(@"Custom targeting : %@", [customTargeting description]);
    }
    
    // Load ad request
    [_interstitial loadRequest:dfpRequest];
}

-(void)showFromViewController:(UIViewController *)controller{
    [self.interstitial presentFromRootViewController:controller];
}

#pragma mark - GADAppEventDelegate methods
/// Called when the interstitial receives an app event.
- (void)interstitial:(GADInterstitial *)interstitial
  didReceiveAppEvent:(NSString *)name
            withInfo:(nullable NSString *)info{
    
    if ([name isEqualToString:@"pubmaticdm"]) {
        if (_notified) {
            NSDictionary *userInfo = nil;
            NSString *errorMessage = @"App event is called unexpetedly";
            userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:kPOBErrorDomain
                                                 code:POBSignalingError
                                             userInfo:userInfo];
            [self.delegate failedWithError:error];
            return;
        }
        _notified = YES;
        _interstitial.delegate = nil;
        _interstitial = nil;
        [self.delegate openWrapPartnerDidWin];
    }
}

#pragma mark - GADInterstitialDelegate methods
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    if (_notified) {
        return;
    }
    
    // If OpenWrap SDK have provided non-zero bid price, expect for app event for fixed time interval, otherwise consider as DFP has won & serving its own ad
    if (!_isAppEventExpected) {
        if (!self.notified) {
            [self.delegate adServerDidWin];
            self.notified = YES;
        }
    } else {
        // Timer to synchronize did recieve and app event callback as their sequence is not fixed
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:SYNC_TIMEOUT_INTEREVAL target:self selector:@selector(syncTimetAction) userInfo:nil repeats:NO];
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    NSError *eventError = nil;
    switch (error.code) {
        case kGADErrorNoFill:
            eventError = [self eventError:error withErrorCode:POBErrorNoAds];
            break;
            
        case kGADErrorInvalidRequest:
            eventError = [self eventError:error withErrorCode:POBErrorInvalidRequest];
            break;
            
        case kGADErrorNetworkError:
            eventError = [self eventError:error withErrorCode:POBErrorNetworkError];
            break;
            
        case kGADErrorTimeout:
            eventError = [self eventError:error withErrorCode:POBErrorTimeout];
            break;
            
        case kGADErrorInternalError:
        case kGADErrorInterstitialAlreadyUsed:
        case kGADErrorMediationDataError:
        case kGADErrorMediationAdapterError:
        case kGADErrorMediationInvalidAdSize:
        case kGADErrorInvalidArgument:
            eventError = [self eventError:error withErrorCode:POBErrorInternalError];
            break;
            
        case kGADErrorReceivedInvalidResponse:
            eventError = [self eventError:error withErrorCode:POBErrorInvalidResponse];
            break;
            
        default:
            eventError = error;
            break;
    }
    
    [_delegate failedWithError:eventError];
}

-(NSError *)eventError:(GADRequestError *)error  withErrorCode:(POBErrorCode )code{
    NSError *eventError = [NSError errorWithDomain:kPOBErrorDomain
                                              code:code
                                          userInfo:error.userInfo];
    return eventError;
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    [self.delegate willPresentAd];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    [self.delegate didDismissAd];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad{
    /*
     GADInterstitialDelegate doesn't provide didClickAd callback. Since user click
     has triggered the willLeaveApplication event, the interstitial event handler
     can safely give didClickAd callback.
     */
    [self.delegate didClickAd];
    [self.delegate willLeaveApp];
}
#pragma mark -

- (void)syncTimetAction{
    if (!self.notified) {
        [self.delegate adServerDidWin];
        self.notified = YES;
    }
}

@end
