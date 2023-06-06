/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2023 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic.
* The intellectual and technical concepts contained herein are proprietary to PubMatic
* and may be covered by U.S. and Foreign Patents, patents in process, and are protected
* by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly
* forbidden unless prior written permission is obtained from PubMatic.
* Access to the source code contained herein is hereby forbidden to anyone except current
* PubMatic employees, managers or contractors who have executed Confidentiality and
* Non-disclosure agreements explicitly covering such access or to such other persons whom
* are directly authorized by PubMatic to access the source code and are subject to
* confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or
* disclosure  of  this source code, which includes information that is confidential
* and/or proprietary, and is a trade secret, of  PubMatic.
* ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC DISPLAY
* OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF
* PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL
* TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION
* DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS
* CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE,
* IN WHOLE OR IN PART.
*/

import UIKit

/**
 Protocol to be implemented by a view controller to get the notification after the responses are received from all the bidders.
 */
protocol BiddingManagerDelegate: AnyObject {
    /**
     @abstract Method to notify manager class on receiving ad response successfully.
     @param response: Response/Targeting information
     */
    func didReceiveResponse(_ response: [String: Any]?)

    /**
    @abstract Method to notify manager class if error occured.
    @param error: Error object
    */
    func didFail(toReceiveResponse error: Error?)
}

/**
 Bidding manager class to manage bids loaded from all the bidders
 of various SDKs, e.g. TAM
 This class internally waits for all the bidders to respond with success/failure and notifies the
 calling class with aggregated response once all responses are received.
 */
class BiddingManager: NSObject,Bidding,BidderDelegate {
    weak var delegate: BidderDelegate?
    
    /**
      delegate for BiddingManagerDelegate protocol to get the callbacks once response from all the bidders are received.
     */
    weak var biddingManagerDelegate: BiddingManagerDelegate?
    
    // Array of registered bidders.
    var biddersList: [Bidding]?
    
    /**
     Queue of registered bidders. It will have same objects as biddersList but, the bidders will be removed from biddersQueue once they respond.
     Objects from biddersList will not be modified.
     */
    var biddersQueue: [Bidding]?
    
    /**
     Combined list of all responses from all the bidders, stored in the form of dictionary
     eg. {bidderName1: response1, bidderName2: response2, ...}
     response1, response2 etc. are key-value pairs of targeting information.
     */
    var responses: [String: Any]?
    
    /// Flag to identify if response from OpenWrap SDK is received.
    var owResponseReceived = false
    
    override init() {
        super.init()
        biddersList = [Bidding]()
        biddersQueue = [Bidding]()
        responses = [String: Any]()
    }

    /**
    @abstract Method to register bidders in bidding manager.
    Separate class should be created for each ad server integration (e.g. TAM) implementing Bidding protocol and should be registered in bidding manager.
    Bidding manager keeps the bidders in a queue, sends load bids request simultaniously
    to all the registered bidders
    @param bidder: Bidder object implementing Bidding protocol
    */
    func registerBidder(_ bidder: Bidding?) {
        // Set bidding delegate to received bidder.
        let newBidder = bidder
        newBidder?.delegate = self
        // Add bidder in bidder's list.
        // Please note, bidders should be registered only once.
        if let unWrappedBidder = newBidder {
            biddersList?.append(unWrappedBidder)
        }
    }
    
    /**
      Method to instruct bidding manager to load bids. Bidding manager internally instructs all the registered bidders to load bids using Bidding protocol.
     */
    func loadBids() {
        biddersQueue = biddersList
        // Reset bidders queue
        responses!.removeAll()
        guard let uBidderQueue = biddersQueue else { return }
        for bidder in uBidderQueue {
            bidder.loadBids()
        }
    }

    // MARK: - BidderDelegate methods
    func bidder(_ bidder: Bidding?, didReceivedAdResponse response: [String: Any]?) {
        // The bidder have responded with success, collect all the responses
        // in responses map and remove it from bidders queue.
        responses = response
        removeRespondedBidder(bidder)
        processResponse()
    }

    func bidder(_ bidder: Bidding?, didFailToReceiveAdWithError error: Error?) {
        // The bidder have responded with failure, so remove it from bidders queue
        removeRespondedBidder(bidder)
        processResponse()
    }
    
    // MARK: - Private methods
    //Method to remove bidder from biddersQueue once it responds with success/failure.
    func removeRespondedBidder(_ bidder: Bidding?) {
        guard let ubiddersQueue = biddersQueue else { return }
        var bidderIndex = 0
        for ubider in ubiddersQueue {
            if ubider === bidder {
                biddersQueue?.remove(at: bidderIndex)
            }
            bidderIndex += 1
        }
    }
    
    /**
     Method to process received responses.
     This internally checks if all the bidders have responded. If yes, it notifies
     view controller about aggregated responses using BiddingManagerDelegate protocol.
     So, it is required to call this method everytime, response is
     received from any bidder.
     */
    func processResponse() {
        // Wait for all the bidders and OpenWrap to respond
        if biddersQueue!.count == 0 && owResponseReceived {
            if responses!.keys.count > 0 {
                biddingManagerDelegate!.didReceiveResponse(responses)
            } else {
                let error = NSError(domain: "Failed to receive targeting from all the bidders.", code: -1, userInfo: nil)
                biddingManagerDelegate!.didFail(toReceiveResponse: error)
            }
            biddersQueue!.removeAll()
            owResponseReceived = false
        }
    }

    /**
     @abstract Method to notify bidding manager about OpenWrap response (success/failure)
     */
    func notifyOpenWrapBidEvent() {
        owResponseReceived = true
        // Call processResponse as OpenWrap's bids are received.
        processResponse()
    }
}
