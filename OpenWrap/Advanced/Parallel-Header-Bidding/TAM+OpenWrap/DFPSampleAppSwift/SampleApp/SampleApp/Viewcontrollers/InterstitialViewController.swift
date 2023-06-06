/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2023 PubMatic, All Rights Reserved.
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

import GoogleMobileAds
import OpenWrapHandlerDFP
import OpenWrapSDK
import UIKit

class InterstitialViewController: UIViewController, BiddingManagerDelegate, POBInterstitialDelegate,
    POBBidEventDelegate {

    private let SLOT_UUID = "4e918ac0-5c68-4fe1-8d26-4e76e8f74831"
    private let OW_AD_UNIT = "/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
    private var interstitial: POBInterstitial!
    @IBOutlet var showAdButton: UIButton!
    private var eventHandler: DFPInterstitialEventHandler!
    private var biddingManager: BiddingManager!
    private var partnerTargeting: NSMutableDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.partnerTargeting = NSMutableDictionary()
        // Initialize bidding manager
        self.biddingManager = BiddingManager()

        // Set bidding manager delegate
        self.biddingManager.biddingManagerDelegate = self

        // Register bidders to bidding manager
        self.registerBidders()

        // Initialize POBInterstitial object
        self.initializeInterstitial()
    }

    func registerBidders() {
        // You can create other bidders here and register to bidding manager.
        // Add TAM bidder
        let tamLoader: TAMAdLoader! = TAMAdLoader(
            size: DTBAdSize.init(interstitialAdSizeWithSlotUUID: SLOT_UUID))
        self.biddingManager.registerBidder(tamLoader)
    }

    func initializeInterstitial() {
        // Create an interstitial custom event handler for your ad server. Make
        // sure you use separate event handler objects to create each interstitial
        // For example, The code below creates an event handler for DFP ad server.
        self.eventHandler = DFPInterstitialEventHandler(adUnitId: DFP_AD_UNIT)

        // Set config block on event handler instance
        weak var weakSelf = self
        eventHandler!.configBlock = { request, bid in
            let customTargeting: NSMutableDictionary = request?.customTargeting as? NSMutableDictionary ?? NSMutableDictionary()
            if let partnerTargeting = weakSelf?.partnerTargeting {
                for key in partnerTargeting.allKeys {
                    if let entries = partnerTargeting.value(forKey: key as? String ?? "") as? [String: String] {
                        customTargeting.addEntries(from: entries)
                    }
                }
            }
            request?.customTargeting = customTargeting as? [String: String]
            weakSelf?.partnerTargeting?.removeAllObjects()
            print("Successfully added targeting from all bidders")
        }

        self.interstitial = POBInterstitial(
            publisherId: PUB_ID,
            profileId: PROFILE_ID,
            adUnitId: OW_AD_UNIT,
            eventHandler: self.eventHandler)

        // Set the delegate
        self.interstitial.delegate = self

        // Set the bid event delegate
        self.interstitial.bidEventDelegate = self
    }

    // MARK: - Load and Show button action methods
    @IBAction func loadAdAction(sender: AnyObject!) {
        // Load bids from other partners (e.g. TAM)
        self.biddingManager.loadBids()

        // Load OpenWrap bids
        self.interstitial.loadAd()
    }

    @IBAction func showAdAction(sender: AnyObject!) {
        if self.interstitial.isReady {
            // Show interstitial ad
            self.interstitial.show(from: self)
        }
    }

    // MARK: - POBInterstitialDelegate
    // Notifies the delegate that an ad has been received successfully.
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        self.showAdButton.isHidden = false
        NSLog("Interstitial : Ad Received")
    }

    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: Error) {
        NSLog("Interstitial : Failed to receive ad with error - %@", error.localizedDescription)
    }

    // Notifies the delegate of an error encountered while showing an ad.
    func interstitial(_ interstitial: POBInterstitial, didFailToShowAdWithError error: Error) {
        NSLog("Interstitial : Failed to show ad with error - %@", error.localizedDescription)
    }

    // Notifies the delegate that the interstitial ad will be presented as a modal on top of the current view controller.
    func interstitialWillPresentAd(_ interstitial: POBInterstitial) {
        NSLog("Interstitial : Will present")
    }

    func interstitialDidPresentAd(_ interstitial: POBInterstitial) {
        NSLog("Interstitial : Did present")
    }

    // Notifies the delegate that the interstitial ad has been animated off the screen.
    func interstitialDidDismissAd(_ interstitial: POBInterstitial) {
        NSLog("Interstitial : Dismissed")
    }

    // Notifies the delegate of ad click
    func interstitialDidClickAd(_ interstitial: POBInterstitial) {
        NSLog("Interstitial : Ad Clicked")
    }

    // Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
    func interstitialWillLeaveApplication(_ interstitial: POBInterstitial) {
        NSLog("Interstitial : Will leave app")
    }

    // MARK: - Bid event delegate methods
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        NSLog("Interstitial : Did receive bid")
        // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
        // Notify bidding manager that OpenWrap's success response is received.
        self.biddingManager.notifyOpenWrapBidEvent()
    }

    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        NSLog("Interstitial : Did fail to receive bid with error - %@", error.localizedDescription)

        // Notify bidding manager that OpenWrap's failure response is received.
        self.biddingManager.notifyOpenWrapBidEvent()
    }

    // MARK: - BiddingManagerDelegate Methods
    func didReceiveResponse(_ response: [String: Any]?) {
        /*!
         This method will be invoked as soon as responses from all the bidders are received.
         Here, client side auction can be performed between the bids available in response dictionary.

         To send the bids targeting to DFP, add targeting from received response in partnerTargeting dictionary. This will be sent to DFP request using config block.
         Config block will be called just before making an ad request to DFP.
         */
        self.partnerTargeting.addEntries(from: response!)
        self.interstitial.proceedToLoadAd()
    }

    func didFail(toReceiveResponse error: Error?) {
        /*!
         No response is available from other bidders, so no need to do anything.
         Just call proceedToLoadAd. OpenWrap SDK will have it's response saved internally
         so it can proceed accordingly.
         */
        NSLog("No targeting received from any bidder")
        self.interstitial.proceedToLoadAd()
    }

    // MARK: - dealloc
    func dealloc() {
        self.interstitial = nil
    }
}
