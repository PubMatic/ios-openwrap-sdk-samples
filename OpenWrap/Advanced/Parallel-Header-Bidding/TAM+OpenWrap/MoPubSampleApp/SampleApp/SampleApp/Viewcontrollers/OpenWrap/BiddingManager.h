/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2022 PubMatic, All Rights Reserved.
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
#import "Bidding.h"

/*!
 Protocol to be implemented by a view controller to get the notification after the responses are received from all the bidders.
 */
@protocol BiddingManagerDelegate <NSObject>

/*!
 @abstract Method to notify manager class on receiving ad response successfully.
 @param response Response/Targeting information
 */
- (void)didReceiveResponse:(NSDictionary *_Nullable)response;

/*!
@abstract Method to notify manager class if error occured.
@param error Error object
*/
- (void)didFailToReceiveResponse:(NSError *_Nullable)error;

@end

/*!
 Bidding manager class to manage bids loaded from all the bidders
 of various SDKs, e.g. TAM
 This class internally waits for all the bidders to respond with success/failure and notifies the calling class with aggregated response once all responses are
 received.
 */
@interface BiddingManager : NSObject <Bidding>

/*!
@abstract Method to register bidders in bidding manager.
Separate class should be created for each ad server integration (e.g. TAM) implementing Bidding protocol and should be registered in bidding manager.
Bidding manager keeps the bidders in a queue, sends load bids request simultaniously
to all the registered bidders
@param bidder  Bidder object implementing Bidding protocol
*/
- (void)registerBidder:(id _Nullable )bidder;

/*!
  delegate for BiddingManagerDelegate protocol to get the callbacks once response from all the bidders are received.
 */
@property (nonatomic, weak) id<BiddingManagerDelegate> _Nullable biddingManagerDelegate;

/*!
 @abstract Method to notify bidding manager about OpenWrap response (success/failure)
 */
- (void)notifyOpenWrapBidEvent;
@end
