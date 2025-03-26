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

import UIKit
import OpenWrapSDK

class RewardedViewController: BaseViewController, POBRewardedAdDelegate, POBBidEventDelegate {
    let owAdUnit  = "OpenWrapRewardedAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1757
    let isOWAuctionWin = true

    var rewardedAd: POBRewardedAd?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Create an rewarded object
        // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        rewardedAd = POBRewardedAd(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit)
        
        // Set the delegate
        rewardedAd?.delegate = self
        
        // Set the bid event delegate
        self.rewardedAd?.bidEventDelegate = self
    }
    
    @IBAction func loadAdAction(_ sender: Any) {
        // Load Ad
        rewardedAd?.loadAd()
    }
    
    @IBAction func showAdAction(_ sender: Any) {
        self.showRewardedAd()
    }
    
    // To show rewarded ad call this function
    func showRewardedAd() {
        // ...
        // Show rewarded ad if it is ready.
        if (rewardedAd?.isReady)! {
            // Show rewarded ad
            rewardedAd?.show(from: self)
        }
    }
    
    // Function simulates auction
    func auctionAndProceedWithBid(bid:POBBid) {
        log("Rewarded Ad : Proceeding with load ad.")
        // Check if bid is expired
        if !bid.isExpired() {
            // Use bid, e.g. perform auction with your in-house mediation setup
            // ..
            // Auction complete
            if isOWAuctionWin {
                // OW bid won in the auction
                // Call rewarded?.proceedToLoadAd() to complete the bid flow
                rewardedAd?.proceedToLoadAd()
            }else{
                // Notify rewarded to proceed with auction loss error.
                rewardedAd?.proceed(
                    onError: POBBidEventErrorCode.clientSideAuctionLoss,
                    andDescription: "Client Side Auction Loss")
            }
        } else {
            // Notify rewarded to proceed with expiry error.
            rewardedAd?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }

    // MARK: - Bid event delegate methods
    // Notifies the delegate that bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid.
        log("Rewarded Ad : Bid received.")
        // Notify rewarded to proceed to load the ad after using the bid.
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify rewarded to proceed with the error.
        log("Rewarded Ad : Bid failed with error : \(error.localizedDescription)")
        rewardedAd?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: Rewarded Ad delegate methods
    // Notifies the delegate that an ad has been received successfully.
    func rewardedAdDidReceive(_ rewardedAd: POBRewardedAd) {
        showAdButton.isEnabled = true
        log("Rewarded Ad : Ad Received")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func rewardedAd(_ rewardedAd: POBRewardedAd, didFailToReceiveAdWithError error: Error) {
        log("Rewarded Ad : Ad failed with error  \(error.localizedDescription)")
    }

    func rewardedAdDidRecordImpression(_ rewardedAd: POBRewardedAd) {
        log("Rewarded Ad : Ad Impression")
    }

    deinit {
        rewardedAd = nil
    }
}
