/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2021 PubMatic, All Rights Reserved.
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
import OpenWrapHandlerDFP

class RewardedAdViewController: UIViewController,POBRewardedAdDelegate {
    @IBOutlet var showAdButton: UIButton!

    let dfpAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-RewardedAd"
    let owAdUnit  = "/15671365/pm_sdk/PMSDK-Demo-App-RewardedAd"
    let pubId = "156276"
    let profileId : NSNumber = 1757

    var rewardedAd: POBRewardedAd?

    override func viewDidLoad() {
        super.viewDidLoad()

        let eventHandler = DFPRewardedEventHandler(adUnitId: dfpAdUnit)

        rewardedAd = POBRewardedAd(
            publisherId: pubId,
            profileId: profileId,
            adUnitId: owAdUnit,
            eventHandler: eventHandler!)
        
        // Set the delegate
        rewardedAd?.delegate = self
    }
    
    @IBAction func loadAdAction(_ sender: Any) {
        rewardedAd?.loadAd()
    }
    
    @IBAction func showAdAction(_ sender: Any) {
        if ((rewardedAd?.isReady) != nil) {
            // Show rewarded ad
            rewardedAd?.show(from: self)
        }
    }
    
    // MARK: - POBRewardedAdDelegate
    // Notifies the delegate that an ad has been received successfully.
    func rewardedAdDidReceive(_ rewardedAd: POBRewardedAd) {
        showAdButton.isHidden = false
        print("RewardedAd : Ad Received")
    }

    // Notifies the delegate of an error encountered while loading an ad.
    func rewardedAd(_ rewardedAd: POBRewardedAd, didFailToReceiveAdWithError error: Error) {
        print("RewardedAd : Failed to receive ad with error : \(error.localizedDescription)")
    }
    
    // Notifies the delegate of an error encountered while showing an ad.
    func rewardedAd(_ rewardedAd: POBRewardedAd, didFailToShowAdWithError error: Error) {
        print("RewardedAd : Failed to show ad with error : \(error.localizedDescription)")
    }
    
    // Notifies the delegate that the rewardedAd ad will be presented as a modal on top of the current view controller.
    func rewardedAdWillPresent(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Will present")
    }

    func rewardedAdDidPresent(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Did present")
    }

    // Notifies the delegate that the rewardedAd ad has been animated off the screen.
    func rewardedAdDidDismiss(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Dismissed")
    }

    // Notifies the delegate of ad click
    func rewardedAdDidClick(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Ad clicked")
    }
    
    // Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
    func rewardedAdWillLeaveApplication(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Will leave app")
    }

    // Notifies the delegate of an ad expiration. After this callback, this 'POBRewardedAd' instance is marked as invalid & will not be shown.
    func rewardedAdDidExpireAd(_ rewardedAd: POBRewardedAd) {
        print("RewardedAd : Expired")
    }

    // Notifies the delegate that a user will be rewarded once the ad is completely viewed.
    func rewardedAd(_ rewardedAd: POBRewardedAd, shouldReward reward: POBReward) {
        print("RewardedAd : Ad should reward \(reward.amount)(\(reward.currencyType))")
    }

    // MARK: - dealloc
    deinit {
        rewardedAd = nil
    }
}
