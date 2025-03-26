/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic.
* The intellectual and technical concepts contained herein are proprietary to PubMatic
* and may be covered by U.S. and Foreign Patents, patents in process, and are protected
* by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly
* forbidden unless prior written permission is obtained from PubMatic.
* Access to the source code contained herein is hereby forbidden to anyone except current
* PubMatic employees, managers or contractors who have executed Confidentiality and
* Non-disclosure agreements explicitly covering such access or to such other persons whom
* are directly authorized by PubMatic to access the source code and are subject to
* confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or
* disclosure  of  this source code, which includes information that is confidential
* and/or proprietary, and is a trade secret, of  PubMatic.
* ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC DISPLAY
* OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF
* PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL
* TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION
* DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS
* CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE,
* IN WHOLE OR IN PART.
*/

import UIKit
import GoogleMobileAds
import OpenWrapSDK
import OpenWrapHandlerDFP

/**
 Protocol to be implemented by view controller to receive the ad receive/ad fail callback
 */
protocol AdLoaderDelegate: AnyObject {
    /**
     Gets called when ad is received successfully.
     @param bannerView Instance of POBBannerView
     */
    func adLoaderDidReceiveAd(adLoader: AdLoader)
    /**
     Gets called when ad loader failed to receive ad
     @param error Instance of NSError which includes error code and its reason
    */
    func adDidFail(bannerView: POBBannerView, error: NSError)
    func viewController() -> UIViewController
}

/**
  This class is responsible to handle OW SDK + TAM parallel header bidding into GAM
  by loading bid from TAM, OpenWrap in parallel manner and provide those bids to GAM SDK.
  After the completion of whole header bidding execution this class provides either success or
  failure callback to it's listener.
 */
class AdLoader: NSObject, POBBidEventDelegate, BiddingManagerDelegate, POBBannerViewDelegate {
    
    var pubid: String
    var profileid: NSNumber
    var owadUnitId: String
    var gamAdUnit: String
    var adsize: AdSize
    var slotid: String
    // Instance of bidding manager
    var biddingManager: BiddingManager
    
    // Banner view
    var bannerView: POBBannerView
    
    // Dictionary to maintain response from different partners
    var partnerTargeting: [String: Any]?
    
    // delegate property to listen ad loader callbacks
    weak var delegate: AdLoaderDelegate?
    
    // Flag to maintain prefetch ad state
    var prefetchAdState: Bool
    var adLoadState: Bool
    
    init(profileId: NSNumber,
         pubId: String,
         owAdUnitId: String,
         gamAdUnitId: String,
         slotId: String,
         adSize: AdSize) {

        pubid = pubId
        profileid = profileId
        owadUnitId = owAdUnitId
        gamAdUnit = gamAdUnitId
        adsize = adSize
        slotid = slotId
        prefetchAdState = false
        adLoadState = false
        // Create bidding manager
        biddingManager = BiddingManager()
        
        // Create event handler
        let eventHandler = DFPBannerEventHandler(adUnitId: gamAdUnit, andSizes: [nsValue(for: adSize)])
        
        // Create a banner view
        bannerView = POBBannerView(publisherId: pubid, profileId:
                                    profileid, adUnitId: owadUnitId,
                                   eventHandler: eventHandler!)!
        
        super.init()
        
        weak var weakSelf = self
        eventHandler!.configBlock = { view, request, bid in
            var customTargeting = request?.customTargeting
            if let partnerTargeting = weakSelf?.partnerTargeting {
                customTargeting = partnerTargeting["TAM"] as? [String: String]
            }
            request?.customTargeting = customTargeting
            weakSelf?.partnerTargeting?.removeAll()
            print("Successfully added targeting from all bidders")
        }
        // Set bidding manager delegate
        biddingManager.biddingManagerDelegate = self

        // Set the delegate
        bannerView.delegate = self

        // Set the bid event delegate
        bannerView.bidEventDelegate = self
    }
    
    func load() {
        prefetchAdState = true

        // Load OpenWrap Bids
        bannerView.loadAd()

        // Load TAM Bids
        let tamLoader = TAMAdLoader(size: DTBAdSize(bannerAdSizeWithWidth: Int(adsize.size.width), height: Int(adsize.size.height), andSlotUUID: slotid))
        biddingManager.registerBidder(tamLoader)
        biddingManager.loadBids()
    }
    
    // MARK: - BidEvent delegate methods
    
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
        // Notify bidding manager that OpenWrap's success response is received.
        biddingManager.notifyOpenWrapBidEvent()
    }
    
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify bidding manager that OpenWrap's failure response is received.
        biddingManager.notifyOpenWrapBidEvent()
    }
    
    // MARK: - BiddingManagerDelegate delegate methods
    func didReceiveResponse(_ response: [String: Any]?) {
        /**
         This method will be invoked as soon as responses from all the bidders are received.
         Here, client side auction can be performed between the bids available in response dictionary.
         To send the bids' targeting to DFP, add targeting from received response in
         partnerTargeting dictionary. This will be sent to DFP request using config block,
         Config block will be called just before making an ad request to DFP.
         */
        partnerTargeting = response
        bannerView.proceedToLoadAd()
    }
    
    func didFail(toReceiveResponse error: Error?) {
        /**
         No response is available from other bidders, so no need to do anything.
         Just call proceedToLoadAd. OpenWrap SDK will have it's response saved internally
         so it can proceed accordingly.
         */
        print("No targeting received from any bidder")
        bannerView.proceedToLoadAd()
    }

    // MARK: - Banner view delegate methods
    
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return (delegate?.viewController())!
    }

    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        adLoadState = true
        delegate?.adLoaderDidReceiveAd(adLoader: self)
        /**
         OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
         To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        */
        biddingManager.loadBids()
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        delegate?.adDidFail(bannerView: bannerView, error: error as Error as NSError)
        /**
         OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
         To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
        */
        biddingManager.loadBids()
    }
}
