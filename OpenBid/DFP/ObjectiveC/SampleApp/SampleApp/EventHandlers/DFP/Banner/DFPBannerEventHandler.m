/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2019 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of
 * PubMatic. The intellectual and technical concepts contained herein are
 * proprietary to PubMatic and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from PubMatic.
 * Access to the source code contained herein is hereby forbidden to anyone
 * except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such
 * access.
 *
 * The copyright notice above does not evidence any actual or intended
 * publication or disclosure  of  this source code, which includes information
 * that is confidential and/or proprietary, and is a trade secret, of  PubMatic.
 * ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC
 * DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN
 * CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE
 * CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS TO
 * REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR
 * SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

#import "DFPBannerEventHandler.h"
#import <POBBid.h>

#define SYNC_TIMEOUT_INTEREVAL 0.6

@interface DFPBannerEventHandler () <GADBannerViewDelegate,
GADAppEventDelegate,
GADAdSizeDelegate>
@property(nonatomic, strong) DFPBannerView *bannerView;
@property(nonatomic) NSTimer *timer;
@property(nonatomic, weak) id<POBBannerEventDelegate> delegate;
@property(nonatomic) CGSize dfpAdSize;
@property(nonatomic, assign) BOOL notified;
@property(nonatomic, assign) BOOL isAppEventExpected;
@property(nonatomic, strong) NSArray *adSizes;
@end

@implementation DFPBannerEventHandler
- (instancetype)initAdunitId:(NSString *)adUnitId
                    andSizes:(NSArray *)validSizes {
    
    self = [super init];
    if (self) {
        
        // Create DFPBannerView and set ad unit and ad sizes
        _bannerView = [[DFPBannerView alloc] init];
        _bannerView.adUnitID = adUnitId;
        
        _adSizes = validSizes;
        [_bannerView setValidAdSizes:validSizes];
        _dfpAdSize = _bannerView.adSize.size;
        
        // Set delegates on DFPBannerView instance, these should not be removed/overridden else event handler will not work as expected.
        _bannerView.delegate = self;
        _bannerView.appEventDelegate = self;
        _bannerView.adSizeDelegate = self;
    }
    return self;
}

- (void)dealloc {
    _bannerView.delegate = nil;
    _bannerView = nil;
    _configBlock = nil;
}

#pragma mark - POBBannerEvent methods

- (void)setDelegate:(id<POBBannerEventDelegate>)delegate {
    _delegate = delegate;
}

// OpenBid SDK passes its bids through this method
- (void)requestAdWithBid:(POBBid *)bid {
    _notified = NO;
    _isAppEventExpected = NO;
    _bannerView.rootViewController = [self.delegate viewControllerForPresentingModal];
    
    // Create DFP ad request
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];
    
    // Call configuration block if set. it can be used to configure DFP banner and ad request
    if (self.configBlock) {
        self.configBlock(_bannerView, dfpRequest);
    }
    
    if (!(_bannerView.appEventDelegate == self &&
        _bannerView.delegate == self)) {
        NSLog(@"Do not set DFP delegates. These are used by DFPBannerEventHandler internally.");
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
    [_bannerView loadRequest:dfpRequest];
}

- (CGSize)adContentSize {
    return _dfpAdSize;
}

- (NSArray<POBAdSize *> *)requestedAdSizes {
    NSMutableArray *sizes = [NSMutableArray new];
    for (NSValue *adSize in _adSizes) {
        GADAdSize gAdSize = GADAdSizeFromNSValue(adSize);
        [sizes addObject:POBAdSizeMakeFromCGSize(gAdSize.size)];
    }
    return [NSArray arrayWithArray:sizes];
}

#pragma mark - GADAppEventDelegate methods

// Called when the banner receives an app event.
- (void)adView:(DFPBannerView *)banner
didReceiveAppEvent:(NSString *)name
      withInfo:(NSString *)info {
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
        [self.delegate openBidPartnerDidWin];
    }
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    
    // If already notifed, skip waiting for app event
    if (_notified) {
        return;
    }
    
    // If OpenBid SDK have provided non-zero bid price, expect for app event for fixed time interval, otherwise consider as DFP has won & serving its own ad
    if (!_isAppEventExpected) {
        [self.delegate adServerDidWin:bannerView];
        self.notified = YES;
    } else {
        // Timer to synchronize did recieve and app event callback as their sequence is not fixed
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:SYNC_TIMEOUT_INTEREVAL target:self selector:@selector(syncTimetAction) userInfo:nil repeats:NO];
    }
}

/// Tells the delegate that an ad request failed. The failure is normally due to
/// network connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error {
    
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
        case kGADErrorMediationNoFill:
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

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    [_delegate willPresentModal];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    [_delegate didDismissModal];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    [_delegate willLeaveApp];
}

#pragma mark - GADAdSizeDelegate methods

- (void)adView:(nonnull GADBannerView *)bannerView
willChangeAdSizeTo:(GADAdSize)size {
    _dfpAdSize = size.size;
}
#pragma mark -

- (void)syncTimetAction{
    if (!self.notified) {
        [self.delegate
         adServerDidWin:_bannerView];
        self.notified = YES;
    }
}

@end
