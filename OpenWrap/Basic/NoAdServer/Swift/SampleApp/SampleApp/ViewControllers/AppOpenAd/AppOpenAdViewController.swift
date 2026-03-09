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

class AppOpenAdViewController: BaseViewController, POBAppOpenAdDelegate {

    let owAdUnit  = "OpenWrapAppOpenAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165

    var appOpenAd: POBAppOpenAd?
    @IBOutlet var showAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an app open ad object
        // For test IDs refer -
        // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        appOpenAd = POBAppOpenAd(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit)

        // Set the delegate
        appOpenAd?.delegate = self
    }

    @IBAction func loadAdAction(_ sender: Any) {
        // Load Ad
        appOpenAd?.load()
    }

    @IBAction func showAdAction(_ sender: Any) {
        self.showAppOpenAd()
    }

    // To show app open ad call this function
    func showAppOpenAd() {
        // ...
        if (appOpenAd?.isReady)! {
            // Show app open ad
            appOpenAd?.show(from: self)
        }
    }

    // MARK: App Open delegate methods

    // Notifies the delegate that an ad has been received successfully.
    func appOpenAdDidReceive(_ appOpenAd: POBAppOpenAd) {
        showAdButton.isEnabled = true
        log("App Open Ad : Ad Received")
    }

    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func appOpenAd(_ appOpenAd: POBAppOpenAd, didFailToReceiveAdWithError error: Error) {
        log("App Open Ad : Failed to receive ad with error  \(error.localizedDescription )")
    }

    // Notifies the delegate of an error encountered while showing an ad.
    func appOpenAd(_ appOpenAd: POBAppOpenAd, didFailToShowAdWithError error: Error) {
        log("App Open Ad : Failed to show ad with error  \(error.localizedDescription )")
    }

    // Notifies the delegate that the app open ad will be presented as a modal on top of the current view controller.
    func appOpenAdWillPresent(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Will present")
    }

    //Notifies the delegate that the app open ad is presented as a modal on top of the current view controller.
    func appOpenAdDidPresent(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Did present")
    }

    // Notifies the delegate that the app open ad has been animated off the screen.
    func appOpenAdDidDismiss(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Dismissed")
    }

    // Notifies the delegate of ad click
    func appOpenAdDidClick(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Ad Clicked")
    }

    // Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
    func appOpenAdWillLeaveApplication(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Will leave app")
    }

    // Notifies the delegate that the app open ad has recorded the impression.
    func appOpenAdDidRecordImpression(_ appOpenAd: POBAppOpenAd) {
        log("App Open Ad : Ad Impression")
    }

    deinit {
        appOpenAd = nil
    }
}
