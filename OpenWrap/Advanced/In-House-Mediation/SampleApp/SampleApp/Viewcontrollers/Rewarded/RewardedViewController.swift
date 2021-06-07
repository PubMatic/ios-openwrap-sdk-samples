

import UIKit
import OpenWrapSDK

class RewardedViewController: UIViewController, POBRewardedAdDelegate, POBBidEventDelegate {
    let owAdUnit  = "OpenWrapRewardedAdUnit"
    let pubId = "156276"
    let profileId : NSNumber = 1757
    let isOWAuctionWin = true

    var rewardedAd: POBRewardedAd?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Create an rewarded object
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
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
        if (rewardedAd?.isReady)! {
            // Show rewarded ad
            rewardedAd?.show(from: self)
        }
    }
    
    // function simulates auction
    func auctionAndProceedWithBid(bid:POBBid) {
        print("Rewarded Ad : Proceeding with load ad.")
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
                rewardedAd?.proceed(onError: POBBidEventErrorCode.clientSideAuctionLoss, andDescription: "Client Side Auction Loss")
            }
        }else{
            // Notify rewarded to proceed with expiry error.
            rewardedAd?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }

    // MARK: - Bid event delegate methods
    // Notifies the delegate that bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid.
        print("Rewarded Ad : Bid received.")
        // Notify rewarded to proceed to load the ad after using the bid.
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify rewarded to proceed with the error.
        print("Rewarded Ad : Bid failed with error : \(error.localizedDescription)")
        rewardedAd?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: Rewarded Ad delegate methods
    // Notifies the delegate that an ad has been received successfully.
    func rewardedAdDidReceive(_ rewardedAd: POBRewardedAd) {
        showAdButton.isHidden = false
        print("Rewarded Ad : Ad Received")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func rewardedAd(_ rewardedAd: POBRewardedAd, didFailToReceiveAdWithError error: Error) {
        print("Rewarded Ad : Ad failed with error  \(error.localizedDescription)")
    }
    deinit {
        rewardedAd = nil
    }
}
