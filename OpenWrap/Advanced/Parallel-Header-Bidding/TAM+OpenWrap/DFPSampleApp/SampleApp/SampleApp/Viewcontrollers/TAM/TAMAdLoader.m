/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
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

#import "TAMAdLoader.h"

#define SLOT_UUID   @"5ab6a4ae-4aa5-43f4-9da4-e30755f2b295"

@interface TAMAdLoader ()
@property (nonatomic, strong) DTBAdSize *adSize;
@end

@implementation TAMAdLoader
@synthesize delegate;

- (instancetype)initWithSize:(DTBAdSize *)size{
    self = [super init];
    if (self) {
        self.adSize = size;
    }
    return self;
}

#pragma mark - Bidding protocol method
// Method to instruct bidder class to load the bid.
- (void)loadBids {
    NSLog(@"TAM : Loading ad from A9 TAM SDK");
    DTBAdLoader *adLoader = [DTBAdLoader new];
    [adLoader setSizes:self.adSize, nil];
    [adLoader loadAd:self];
}

#pragma mark - DTBAdCallback

- (void)onFailure:(DTBAdError)error {
    NSLog(@"TAM : Failed to load ad with error :%d", error);
    NSError *err = [[NSError alloc] initWithDomain:@"Failed to load ad from TAM SDK." code:error userInfo:nil];
    // Notify failure to bidding manager
    [self.delegate bidder:self didFailToReceiveAdWithError:err];
}

- (void)onSuccess:(DTBAdResponse *)adResponse {
    NSLog(@"TAM : Received Response From A9 TAM SDK");
    // Pass TAM custom targeting parameters to bidding manager.
    [self.delegate bidder:self didReceivedAdResponse:@{@"TAM":[adResponse customTargeting]}];
}

@end
