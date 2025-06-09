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

import DTBiOSSDK
import GoogleMobileAds
import OpenWrapHandlerDFP
import OpenWrapSDK
import UIKit

class BannerViewController: BaseViewController, POBBannerViewDelegate, POBBidEventDelegate,
    BiddingManagerDelegate {

    // A9 TAM slot id 320x50 banner
    private let SLOT_UUID = "5ab6a4ae-4aa5-43f4-9da4-e30755f2b295"
    let OW_AD_UNIT = "/15671365/pm_sdk/PMSDK-Demo-App-Banner"

    private var _bannerView: POBBannerView!
    private var bannerView: POBBannerView! {
        get { return _bannerView }
        set { _bannerView = newValue }
    }
    private var _eventHandler: DFPBannerEventHandler!
    private var eventHandler: DFPBannerEventHandler! {
        get { return _eventHandler }
        set { _eventHandler = newValue }
    }
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

        // Initialize POBBannerView object
        self.initializeOpenWrapBannerView()

        // Request bidding manager to load bids from all the connected bidders.
        self.biddingManager.loadBids()

        // Load OpenWrap bids
        self.bannerView.loadAd()
    }

    func registerBidders() {
        // You can create other bidders here and register to bidding manager.
        // Add TAM as a bidder
        let tamLoader: TAMAdLoader! = TAMAdLoader(
            size: DTBAdSize.init(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: SLOT_UUID))
        self.biddingManager.registerBidder(tamLoader)
    }

    func initializeOpenWrapBannerView() {
        let adSizes: [NSValue]! = [nsValue(for: AdSizeBanner)]

        // Create a banner custom event handler for your ad server. Make sure you use
        // separate event handler objects to create each banner view.
        //For example, The code below creates an event handler for DFP ad server.
        self.eventHandler = DFPBannerEventHandler(adUnitId: DFP_AD_UNIT, andSizes: adSizes)

        // Set config block on event handler instance
        eventHandler.configBlock = { [weak self] _, request, _ in
            guard let self else { return }
            let customTargeting = request?.customTargeting as? NSMutableDictionary ?? NSMutableDictionary()
            if let partnerTargeting {
                for key in partnerTargeting.allKeys {
                    if let entries = partnerTargeting.value(forKey: key as? String ?? "") as? [String: String] {
                        customTargeting.addEntries(from: entries)
                    }
                }
                partnerTargeting.removeAllObjects()
            }
            request?.customTargeting = customTargeting as? [String: String]
            log("Successfully added targeting from all bidders")
        }
        // Create a banner view
        self.bannerView = POBBannerView(
            publisherId: PUB_ID,
            profileId: PROFILE_ID,
            adUnitId: OW_AD_UNIT,
            eventHandler: self.eventHandler)

        self.bannerView.delegate = self

        self.bannerView.bidEventDelegate = self

        // Add the banner view to your view hierarchy
        self.addBannerToView(
            bannerView: self.bannerView, withSize: CGSize.init(width: 320, height: 50))
    }

    // MARK: - Banner view delegate methods
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }

    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        log("Banner : Ad received with size \(bannerView.creativeSize())")
        /*!
         OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
         To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        */
        self.biddingManager.loadBids()
    }

    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        log("Banner : Ad failed with error : \(error.localizedDescription)")
        /*!
         OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
         To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        */
        self.biddingManager.loadBids()
    }

    // Notifies the delegate whenever current app goes in the background due to user click
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        log("Banner : Will leave app")
    }

    // Notifies the delegate that the banner ad view will launch a modal on top of the current view controller,
    // as a result of user interaction.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        log("Banner : Will present modal")
    }

    // Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        log("Banner : Dismissed modal")
    }

    // Notifies the delegate that the banner view was clicked.
    func bannerViewDidClickAd(_ bannerView: POBBannerView) {
        log("Banner : Ad clicked")
    }

    // Notifies the delegate that an ad impression has been recorded.
    func bannerViewDidRecordImpression(_ bannerView: POBBannerView) {
        log("Banner : Ad Impression")
    }

    // MARK: - Bid event delegate methods
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        log("Banner : Did receive bid")
        // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
        // Notify bidding manager that OpenWrap's success response is received.
        self.biddingManager.notifyOpenWrapBidEvent()
    }

    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        log("Banner : Did fail to receive bid with error - \(error.localizedDescription)")

        // Notify bidding manager that OpenWrap's failure response is received.
        self.biddingManager.notifyOpenWrapBidEvent()
    }

    // MARK: - BiddingManagerDelegate Methods
    func didReceiveResponse(_ response: [String: Any]?) {
        /*!
         This method will be invoked as soon as responses from all the bidders are received.
         Here, client side auction can be performed between the bids available in response dictionary.
         To send the bids' targeting to DFP, add targeting from received response in
         partnerTargeting dictionary. This will be sent to DFP request using config block,
         Config block will be called just before making an ad request to DFP.
         */
        self.partnerTargeting.addEntries(from: response!)
        self.bannerView.proceedToLoadAd()
    }

    func didFail(toReceiveResponse error: Error?) {
        /*!
         No response is available from other bidders, so no need to do anything.
         Just call proceedToLoadAd. OpenWrap SDK will have it's response saved internally
         so it can proceed accordingly.
         */
        log("No targeting received from any bidder")
        self.bannerView.proceedToLoadAd()
    }

    // MARK: - dealloc
    func dealloc() {
        _bannerView = nil
    }

    func addBannerToView(bannerView: UIView!, withSize size: CGSize) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)

        bannerView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        bannerView.widthAnchor.constraint(equalToConstant: size.width).isActive = true

        if #available(iOS 11.0, *) {
            let guide: UILayoutGuide! = self.view.safeAreaLayoutGuide
            bannerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            bannerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        } else {
            let margins: UILayoutGuide! = self.view.layoutMarginsGuide
            bannerView.bottomAnchor.constraint(equalTo: margins.topAnchor).isActive = true
            bannerView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        }
    }
}
