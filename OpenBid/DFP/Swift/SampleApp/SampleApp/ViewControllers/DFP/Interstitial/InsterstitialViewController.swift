/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2019 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of
 * PubMatic. The intellectual and technical concepts contained herein are
 * proprietary to PubMatic and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from PubMatic.
 * Access to the source code contained herein is hereby forbidden to anyone
 * except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such
 * access.
 *
 * The copyright notice above does not evidence any actual or intended
 * publication or disclosure  of  this source code, which includes information
 * that is confidential and/or proprietary, and is a trade secret, of  PubMatic.
 * ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC
 * DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN
 * CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE
 * CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS TO
 * REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR
 * SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

import UIKit
import GoogleMobileAds

class InsterstitialViewController: UIViewController,POBInterstitialDelegate {

    let dfpAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
    let owAdUnit  = "/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
    let pubId = "156276"
    let profileId : NSNumber = 1165

    var interstitial: POBInterstitial?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an interstitial custom event handler for your ad server. Make
        // sure you use separate event handler objects to create each interstitial
        // For example, The code below creates an event handler for DFP ad server.
        let eventHandler = DFPInterstitialEventHandler(dfpAdUnit)
        
        // Create an interstitial object
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
        interstitial = POBInterstitial(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler)
        
        // Set the delegate
        interstitial?.delegate = self
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

    deinit {
        interstitial = nil
    }
}
