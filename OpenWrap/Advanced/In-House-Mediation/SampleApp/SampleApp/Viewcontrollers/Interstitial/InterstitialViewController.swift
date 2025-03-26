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

class InterstitialViewController: BaseViewController, POBInterstitialDelegate, POBBidEventDelegate {

    let owAdUnit  = "OpenWrapInterstitialAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    let isOWAuctionWin = true

    var interstitial: POBInterstitial?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an interstitial object
        // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        interstitial = POBInterstitial(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit)
        
        // Set the delegate
        interstitial?.delegate = self
        
        // Set the bid event delegate
        self.interstitial?.bidEventDelegate = self
    }
    
    @IBAction func loadAdAction(_ sender: Any) {
        // Load Ad
        interstitial?.loadAd()
    }
    
    @IBAction func showAdAction(_ sender: Any) {
        self.showInterstitialAd()
    }
    
    // To show interstitial ad call this function
    func showInterstitialAd() {
        // ...
        if (interstitial?.isReady)! {
            // Show interstitial ad
            interstitial?.show(from: self)
        }
    }
    
    // function simulates auction
    func auctionAndProceedWithBid(bid:POBBid) {
        log("Interstitial : Proceeding with load ad.")
        // Check if bid is expired
        if !bid.isExpired() {
            // Use bid, e.g. perform auction with your in-house mediation setup
            // ..
            // Auction complete
            if isOWAuctionWin {
                // OW bid won in the auction
                // Call interstitial?.proceedToLoadAd() to complete the bid flow
                interstitial?.proceedToLoadAd()
            }else{
                // Notify interstitial to proceed with auction loss error.
                interstitial?.proceed(onError: POBBidEventErrorCode.clientSideAuctionLoss, andDescription: "Client Side Auction Loss")
            }
        }else{
            // Notify interstitial to proceed with expiry error.
            interstitial?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }

    // MARK: - Bid event delegate methods
    // Notifies the delegate that bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid.
        log("Interstitial : Bid received.")
        // Notify interstitial to proceed to load the ad after using the bid.
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify interstitial to proceed with the error.
        log("Interstitial : Bid failed with error : \(error.localizedDescription)")
        interstitial?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: Interstitial delegate methods
    // Notifies the delegate that an ad has been received successfully.
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        showAdButton.isEnabled = true
        log("Interstitial : Ad Received")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: Error) {
        log("Interstitial : Ad failed with error  \(error.localizedDescription )")
    }
    
    // Notifies the delegate of an error encountered while showing an ad
    func interstitial(_ interstitial: POBInterstitial, didFailToShowAdWithError error: Error) {
        log("Interstitial : Failed to show ad with error  \(error.localizedDescription )")
    }

    func interstitialDidRecordImpression(_ interstitial: POBInterstitial) {
        log("Interstitial : Ad Impression")
    }

    deinit {
        interstitial = nil
    }
}
