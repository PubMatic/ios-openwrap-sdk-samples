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

#import "POBBannerCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBBannerCustomEvent()<POBAdRendererDelegate>
@property (nonatomic, strong) id<POBBannerRendering> bannerRenderer;
@end

@implementation POBBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info{
    POBBid *bid = self.localExtras[@"pob_bid"];
    _bannerRenderer = [POBRenderer bannerRenderer];
    [_bannerRenderer setDelegate:self];
    [_bannerRenderer renderAdDescriptor:bid];
}

#pragma mark - PMAdRendererDelegate
- (void)rendererDidRenderAd:(id)renderedAd forDescriptor:(id<POBAdDescriptor>)ad {
    UIView *rendererView = renderedAd;
    POBBid *bid = self.localExtras[@"pob_bid"];
    rendererView.frame = CGRectMake(0, 0, bid.size.width, bid.size.height);
    [self.delegate bannerCustomEvent:self didLoadAd:renderedAd];
}

- (void)rendererDidFailToRenderAdWithError:(NSError *)error forDescriptor:(id<POBAdDescriptor>)ad {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)rendererWillPresentModal {
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)rendererDidDismissModal {
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)rendererWillLeaveApp {
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (UIViewController *)viewControllerForPresentingModal {
    return [self.delegate viewControllerForPresentingModalView];
}

@end
