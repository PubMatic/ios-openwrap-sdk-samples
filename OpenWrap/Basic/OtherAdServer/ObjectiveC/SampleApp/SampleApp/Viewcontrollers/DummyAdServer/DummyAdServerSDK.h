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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DummyAdServerDelegate <NSObject>
@optional
// called when a banner ad is loaded
- (void)didLoadBannerAd:(UIView *)bannerView;

// called when a interstitial ad is loaded
- (void)didReceiveInterstitialAd;

// called when the SDK fails to load an ad
- (void)didFailWithError:(NSError *)error;

// A dummy custom event triggered based on targeting information sent in the request.
- (void)didReceiveCustomEvent:(NSString*)event;

@end

@interface DummyAdServerSDK : NSObject

/*!
 @abstract Initializes & returns a newly allocated DummyAdServerSDK object.
 @param adUnit Ad unit id used to identify unique placement on screen.
 @result Instance of DummyAdServerSDK
 */
- (instancetype)initWithAdUnit:(NSString *)adUnit;

// Ad unit id of ad server SDK
@property(nonatomic, strong) NSString *adUnitId;

// Delegate to receive ad success/failure events.
@property(nonatomic, weak) id<DummyAdServerDelegate> delegate;

// loads a banner ad from the ad server
- (void)loadBannerAd;

// loads an interstitial ad from the ad server
- (void)loadInterstitailAd;

// Presents an interstitial ad
- (void)showInterstitialFromViewController:(UIViewController *)viewController;

// Sets custom targeting to be sent in the ad call
- (void)setCustomTargeting:(NSDictionary *)targeting;

@end
NS_ASSUME_NONNULL_END
