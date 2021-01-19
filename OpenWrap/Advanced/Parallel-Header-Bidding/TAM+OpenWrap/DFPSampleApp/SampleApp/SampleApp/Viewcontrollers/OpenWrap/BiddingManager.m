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

#import "BiddingManager.h"

@interface BiddingManager ()<BidderDelegate>
// Array of registered bidders.
@property (strong, nonatomic) NSMutableArray *biddersList;

/*!
 Queue of registered bidders. It will have same objects as biddersList but, the bidders will be removed from biddersQueue once they respond.
 Objects from biddersList will not be modified.
 */
@property (strong, nonatomic) NSMutableArray *biddersQueue;

/*!
 Combined list of all responses from all the bidders, stored in the form of dictionary
 eg. {bidderName1: response1, bidderName2: response2, ...}
 response1, response2 etc. are key-value pairs of targeting information.
 */
@property (strong, nonatomic) NSMutableDictionary *responses;

// Flag to identify if response from OpenWrap SDK is received.
@property (nonatomic, assign) BOOL owResponseReceived;
@end

@implementation BiddingManager
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.biddersList  = [NSMutableArray new];
        self.biddersQueue = [NSMutableArray new];
        self.responses    = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerBidder:(id<Bidding>)bidder {
    // Set bidding delegate to received bidder.
    bidder.delegate = self;
    // Add bidder in bidder's list.
    // Please note, bidders should be registered only once.
    [self.biddersList addObject:bidder];
}

/*!
  Method to instruct bidding manager to load bids. Bidding manager internally instructs all the registered bidders to load bids using Bidding protocol.
 */
- (void)loadBids {
    // Reset bidders queue
    self.biddersQueue = [NSMutableArray arrayWithArray:self.biddersList];
    [self.responses removeAllObjects];
    for (id<Bidding> bidder in self.biddersQueue) {
        [bidder loadBids];
    }
}

#pragma mark - BidderDelegate methods
- (void)bidder:(id<Bidding>)bidder didReceivedAdResponse:(NSDictionary *)response {
    // The bidder have responded with success, collect all the responses in responses map and remove it from bidders queue.
    [self.responses addEntriesFromDictionary:response];
    [self removeRespondedBidder:bidder];
    [self processResponse];
}

- (void)bidder:(id<Bidding>)bidder didFailToReceiveAdWithError:(NSError *)error {
    // The bidder have responded with failure, so remove it from bidders queue
    [self removeRespondedBidder:bidder];
    [self processResponse];
}

#pragma mark - Private methods
//Method to remove bidder from biddersQueue once it responds with success/failure.
- (void)removeRespondedBidder:(id<Bidding>)bidder {
    if ([self.biddersQueue containsObject:bidder]) {
        [self.biddersQueue removeObject:bidder];
    }
}

/*!
 Method to process received responses.
 This internally checks if all the bidders have responded. If yes, it notifies
 view controller about aggregated responses using BiddingManagerDelegate protocol.
 So, it is required to call this method everytime, response is
 received from any bidder.
 */
- (void)processResponse {
     // Wait for all the bidders and OpenWrap to respond
    if ([self.biddersQueue count] == 0 && self.owResponseReceived) {
        if ([[self.responses allKeys] count] > 0) {
            [self.biddingManagerDelegate didReceiveResponse:self.responses];
        }
        else {
            NSError *error = [NSError errorWithDomain:@"Failed to receive targeting from all the bidders." code:-1 userInfo:nil];
            [self.biddingManagerDelegate didFailToReceiveResponse:error];
        }
        [self.biddersQueue removeAllObjects];
        self.owResponseReceived = NO;
    }
}

// Method to notify that response from OpenWrap SDK is received.
- (void)notifyOpenWrapBidEvent {
    self.owResponseReceived = YES;
    // Call processResponse as OpenWrap's bids are received.
    [self processResponse];
}
@end
