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


#import "POBInterstitialCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBInterstitialCustomEvent () <POBInterstitialRendererDelegate>
@property (nonatomic, strong) id<POBInterstitialRendering> currentRenderer;
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation POBInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    POBBid *bid = self.localExtras[@"pob_bid"];
    _currentRenderer = [POBRenderer interstitialRenderer];
    [_currentRenderer setDelegate:self];
    [_currentRenderer renderAdDescriptor:bid];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    self.viewController = rootViewController;
    NSDictionary *customData = self.localExtras[@"customData"];
    NSNumber *loadTimeOrientation = customData[@"loadTimeOrientation"];
    [_currentRenderer showFromViewController:_viewController
                               inOrientation:loadTimeOrientation.integerValue];
}

#pragma mark - PMInterstitialRendererDelegate

- (void)interstitialRendererDidRenderAd {
    [self.delegate interstitialCustomEvent:self didLoadAd:[UIView new]];
}

- (void)interstitialRendererDidFailToRenderAdWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialRendererDidClick {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialRendererWillLeaveApp {
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)interstitialRendererWillPresentModal {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialRendererDidDismissModal {
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (UIViewController *)viewControllerForPresentingModal {
    return _viewController;
}

@end
