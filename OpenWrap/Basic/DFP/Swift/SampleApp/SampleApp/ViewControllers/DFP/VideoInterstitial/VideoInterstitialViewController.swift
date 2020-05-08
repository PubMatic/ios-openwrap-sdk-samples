

import UIKit
import GoogleMobileAds

class VideoInterstitialViewController: UIViewController,POBInterstitialDelegate, POBInterstitialVideoDelegate {

    let dfpAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
    let owAdUnit  = "/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
    let pubId = "156276"
    let profileId : NSNumber = 1757

    var interstitial: POBInterstitial?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an interstitial custom event handler for your ad server. Make
        // sure you use separate event handler objects to create each interstitial
        // For example, The code below creates an event handler for DFP ad server.
        let eventHandler = DFPInterstitialEventHandler(adUnitId: dfpAdUnit)
        
        // Create an interstitial object
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
        interstitial = POBInterstitial(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler!)
        
        // Set the delegate
        interstitial?.delegate = self
        
        // Set video delegate to receive VAST based video events
        interstitial?.videoDelegate = self
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
    
    // Notifies the delegate of an ad expiration. After this callback, this 'POBInterstitial' instance is marked as invalid & will not be shown.
    func interstitialDidExpireAd(_ interstitial: POBInterstitial) {
        print("Interstitial : Ad Expired")
    }
    
    //MARK: POBInterstitialVideoDelegate methods

    // Notifies the delegate of VAST based video ad events
    func interstitialDidFinishVideoPlayback(_ interstitial: POBInterstitial) {
        print("Interstitial : Finished video playback")
    }

    deinit {
        interstitial = nil
    }
}
