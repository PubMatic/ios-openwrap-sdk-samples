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

#import <Foundation/Foundation.h>

@protocol Bidding;

/*!
 BidderDelegate protocol, which is used to provide response from different partners to bidding manager
 */
@protocol BidderDelegate <NSObject>

/*!
@abstract Method to notify manager class on receiving bids successfully by bidder.
@param bidder Object of a bidder sending notification
@param response Targeting information as a dictionary. Example - @{bidderName : Response}
 */
- (void)bidder:(id<Bidding>)bidder didReceivedAdResponse:(NSDictionary *)response;

/*!
@abstract Method to notify manager class on receiving failure while fetching bids by bidder.
@param bidder Object of a bidder sending notification
@param error Error object
 */
- (void)bidder:(id<Bidding>)bidder didFailToReceiveAdWithError:(NSError *)error;

@end

/*!
 Protocol to be implemented by all the classes that are fetching bids
 from ad servers.
 Separate class should be created for each ad server integrations (e.g. TAM)
 and that class should implement this protocol in order to manage all the bids at one place i.e. bidding manager.
 */
@protocol Bidding <NSObject>
/*!
 This property of BidderDelegate can be used to notify below events to bidding manager
 e.g bids received, bids failed.
 */
@property (nonatomic, assign) id<BidderDelegate> delegate;

/*!
 Method to instruct bidder class to load the bid.
 */
- (void)loadBids;
@end
