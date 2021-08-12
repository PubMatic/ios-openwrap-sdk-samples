

import UIKit
import OpenWrapSDK

class InterstitialViewController: UIViewController,POBInterstitialDelegate,POBBidEventDelegate {

    let owAdUnit  = "OpenWrapInterstitialAdUnit"
    let pubId = "156276"
    let profileId : NSNumber = 1165
    let isOWAuctionWin = true

    var interstitial: POBInterstitial?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an interstitial object
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
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
        print("Interstitial : Proceeding with load ad.")
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
        print("Interstitial : Bid received.")
        // Notify interstitial to proceed to load the ad after using the bid.
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify interstitial to proceed with the error.
        print("Interstitial : Bid failed with error : \(error.localizedDescription)")
        interstitial?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: Interstitial delegate methods
    // Notifies the delegate that an ad has been received successfully.
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        showAdButton.isHidden = false
        print("Interstitial : Ad Received")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: Error) {
        print("Interstitial : Ad failed with error  \(error.localizedDescription )")
    }
    
    // Notifies the delegate of an error encountered while showing an ad
    func interstitial(_ interstitial: POBInterstitial, didFailToShowAdWithError error: Error) {
        print("Interstitial : Failed to show ad with error  \(error.localizedDescription )")
    }

    deinit {
        interstitial = nil
    }
}
