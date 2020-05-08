

import UIKit

class MoPubInterstitialViewController: UIViewController, POBInterstitialDelegate {
    
    let mopubAdUnit         = "61ea16f261fd4d55bb08eb8e9ddb52e3"
    let owAdUnit            = "61ea16f261fd4d55bb08eb8e9ddb52e3"
    let pubId               = "156276"
    let profileId: NSNumber = 1302
    
    @IBOutlet var showAdButton: UIButton!
    var interstitial: POBInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an interstitial custom event handler for your ad server. Make
        // sure you use separate event handler objects to create each interstitial
        // ad instance.
        // For example, The code below creates an event handler for MoPub ad server.
        let eventHandler = MoPubInterstitialEventHandler(adUnitId: mopubAdUnit)
        
        // Create an interstitial object
        // For test IDs refer - https://community.pubmatic.com/x/_xQ5AQ#TestandDebugYourIntegration-TestProfile/Placements
        interstitial = POBInterstitial(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler!)
        
        // Set the delegate
        interstitial?.delegate = self
    }
    
    
    // MARK: - IBActions
    @IBAction func loadAdAction(_ sender: Any) {
        // Load Ad
        interstitial?.loadAd()
    }
    
    @IBAction func showAdAction(_ sender: Any) {
        self.showInterstitialAd()
    }
    
    // To show interstitial ad call this function
    func showInterstitialAd() {
        // Ensure ad is ready to display
        if (interstitial?.isReady)! {
            // Show interstitial ad
            interstitial?.show(from: self)
        }
    }

    deinit {
        interstitial = nil
    }
    
    //MARK: Interstitial delegate methods
    
    // Notifies the delegate that an ad has been received successfully.
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        showAdButton.isHidden = false
        print("Interstitial : Ad Received")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: Error?) {
        print("Interstitial : Ad failed with error  \(error?.localizedDescription ?? "")")
    }
    
    // Notifies the delegate that the interstitial ad will be presented as a modal on top of the current view controller.
    func interstitialWillPresentAd(_ interstitial: POBInterstitial) {
        print("Interstitial : Will present")
    }
    
    // Notifies the delegate that the interstitial ad has been animated off the screen.
    func interstitialDidDismissAd(_ interstitial: POBInterstitial) {
        print("Interstitial : Dismissed")
    }
    
    // Notifies the delegate of ad click
    func interstitialDidClickAd(_ interstitial: POBInterstitial) {
        print("Interstitial : Ad Clicked")
    }
    
    // Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
    func interstitialWillLeaveApplication(_ interstitial: POBInterstitial) {
        print("Interstitial : Will leave app")
    }
}
