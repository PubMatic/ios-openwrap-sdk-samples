/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2020 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
* herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
* from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
* Confidentiality and Non-disclosure agreements explicitly covering such access or to such other persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
* information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
* OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
* LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
* TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
*/
#import "DummyAdServerSDK.h"

static NSString *const CUSTOM_EVENT = @"SomeCustomEvent";

// Emulates an Ad Server SDK
@implementation DummyAdServerSDK

- (instancetype)initWithAdUnit:(NSString *)adUnit {
    self = [super init];
    if (self) {
        _adUnitId = adUnit;
    }
    return self;
}

- (void)loadBannerAd {
    // Usually, the ad server determines whether the partner bid won in the
    // auction, based on provided targeting information. Then, the ad server SDK
    // will either render the banner ad or indicate that a partner ad should be
    // rendered.
    if ([_adUnitId isEqualToString:@"OtherASBannerAdUnit"]) {
        [self.delegate didReceiveCustomEvent:CUSTOM_EVENT];
    }else{
        [self.delegate didLoadBannerAd:[UIView new]];
    }
}

- (void)loadInterstitailAd {
    // Usually, the ad server determines whether the partner bid won in the
    // auction, based on provided targeting information. Then, the ad server SDK
    // will either load the interstitial ad or indicate that a partner ad should
    // be rendered.
    if ([_adUnitId isEqualToString:@"OtherASInterstitialAdUnit"]) {
        [self.delegate didReceiveCustomEvent:CUSTOM_EVENT];
    }else{
        [self.delegate didReceiveInterstitialAd];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController {
    // This implementation of your ad server SDK's interstitial ad presents an
    // interstitial ad
}

- (void)setCustomTargeting:(NSDictionary *)targeting{
    // Sets custom targeting to be sent in the ad call
}

@end
