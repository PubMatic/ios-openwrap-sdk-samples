/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2024 PubMatic, All Rights Reserved.
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
protocol NativeAndBannerAdLoaderDelegate: AnyObject {
    /**
     Gets called when banner ad is received successfully.
     @param adLoader Instance of NativeAndBannerAdLoader
     */
    func nativeBannerAdLoaderDidReceiveBannerAd(adLoader: NativeAndBannerAdLoader)

    /**
     Gets called when native ad is received successfully.
     @param adLoader Instance of NativeAndBannerAdLoader
     */
    func nativeBannerAdLoaderDidReceiveNativeAd(adLoader: NativeAndBannerAdLoader)

    /**
     Gets called when custom native ad is received successfully.
     @param adLoader Instance of NativeAndBannerAdLoader
     */
    func nativeBannerAdLoaderDidReceiveCustomNativeAd(adLoader: NativeAndBannerAdLoader)

    /**
     Gets called when ad loader failed to receive ad
     @param adLoader Instance of NativeAndBannerAdLoader
     @param error Instance of NSError which includes error code and its reason
    */
    func nativeBannerAdLoaderDidFail(adLoader: NativeAndBannerAdLoader, error: NSError)

    /**
     Returns UIViewController to show banner ad
     @return instance of UIViewController
    */
    func viewControllerForNativeBannerAd() -> UIViewController
}

/**
  This class is responsible to handle OW SDK + TAM parallel header bidding into GAM
  by loading bid from TAM, OpenWrap in parallel manner and provide those bids to GAM SDK.
  After the completion of whole header bidding execution this class provides either success or
  failure callback to it's listener.
 */
class NativeAndBannerAdLoader: NSObject, POBBidEventDelegate, BiddingManagerDelegate, POBBannerViewDelegate, POBGAMNativeAdDelegate, POBGAMCustomNativeAdDelegate, GADNativeAdDelegate, GADCustomNativeAdDelegate {

    var pubid: String
    var profileid: NSNumber
    var owadUnitId: String
    var gamAdUnit: String
    var adsize: GADAdSize
    var slotid: String
    // Instance of bidding manager
    var biddingManager: BiddingManager

    // Banner view
    var bannerView: POBBannerView

    // Native ad view
    var nativeAdView: UIView?

    // Dictionary to maintain response from different partners
    var partnerTargeting: [String: Any]?

    // delegate property to listen ad loader callbacks
    weak var delegate: NativeAndBannerAdLoaderDelegate?

    // Flag to maintain prefetch ad state
    var prefetchAdState: Bool
    var adLoadState: Bool

    init(profileId: NSNumber,
         pubId: String,
         owAdUnitId: String,
         gamAdUnitId: String,
         slotId: String,
         adSize: GADAdSize) {

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
        let eventHandler = GAMNativeEventHandler(adUnitId: gamAdUnit, adTypes: [GADAdLoaderAdType.native, GADAdLoaderAdType.customNative], options: nil, andSizes: [NSValueFromGADAdSize(adSize)])

        // Create a banner view
        bannerView = POBBannerView(publisherId: pubid, profileId:
                                    profileid, adUnitId: owadUnitId,
                                   eventHandler: eventHandler)!

        super.init()

        weak var weakSelf = self
        eventHandler.configBlock = { request, bid in
            var customTargeting = request.customTargeting
            if let partnerTargeting = weakSelf?.partnerTargeting {
                customTargeting = partnerTargeting["TAM"] as? [String: String]
            }
            request.customTargeting = customTargeting
            weakSelf?.partnerTargeting?.removeAll()
            print("Successfully added targeting from all bidders")
        }
        // Set bidding manager delegate
        biddingManager.biddingManagerDelegate = self

        // Set the delegate
        bannerView.delegate = self

        eventHandler.nativeDelegate = self
        eventHandler.customNativeDelegate = self

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
}

// MARK: - POBBanner view delegate methods
extension NativeAndBannerAdLoader {

    // MARK: POBBanner view delegate methods
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return (delegate?.viewControllerForNativeBannerAd())!
    }

    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        adLoadState = true
        delegate?.nativeBannerAdLoaderDidReceiveBannerAd(adLoader: self)
    }

    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        delegate?.nativeBannerAdLoaderDidFail(adLoader: self, error: error as NSError)
    }

    // MARK: BidEvent delegate methods
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
        // Notify bidding manager that OpenWrap's success response is received.
        biddingManager.notifyOpenWrapBidEvent()
    }

    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify bidding manager that OpenWrap's failure response is received.
        biddingManager.notifyOpenWrapBidEvent()
    }

    // MARK: - Helper methods
    // Show native ad
    func showNativeAd(nativeAd: GADNativeAd) {
        // Add new ad view and set constraints to fill its container.
        // Create and place ad in view hierarchy.
        let gadNativeAdView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        if gadNativeAdView != nil {
            nativeAdView = gadNativeAdView!

            // Populate the native ad view with the native ad assets.
            // The headline and mediaContent are guaranteed to be present in every native ad.
            (gadNativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline

            // Setup media view
            if gadNativeAdView?.mediaView != nil {
                gadNativeAdView?.mediaView?.mediaContent = nativeAd.mediaContent
                gadNativeAdView?.mediaView?.isHidden = (nativeAd.mediaContent.mainImage == nil)

                // This app uses a fixed width for the GADMediaView and changes its height
                // to match the aspect ratio of the media content it displays.
                if nativeAd.mediaContent.aspectRatio > 0 {
                    let heightConstraint = NSLayoutConstraint.init(item: gadNativeAdView!.mediaView!, attribute: .height, relatedBy: .equal, toItem: gadNativeAdView!.mediaView, attribute: .width, multiplier: (1/nativeAd.mediaContent.aspectRatio), constant: 0)
                    heightConstraint.isActive = true
                }
            }

            // These assets are not guaranteed to be present. Check that they are before
            // showing or hiding them.
            (gadNativeAdView!.bodyView as? UILabel)?.text = nativeAd.body
            gadNativeAdView!.bodyView?.isHidden = ((nativeAd.body ?? "").count == 0)

            (gadNativeAdView!.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            gadNativeAdView!.callToActionView?.isHidden = ((nativeAd.callToAction ?? "").count == 0)

            (gadNativeAdView!.iconView as? UIImageView)?.image = nativeAd.icon?.image
            gadNativeAdView!.iconView?.isHidden = (nativeAd.icon == nil)

            (gadNativeAdView!.starRatingView as? UIImageView)?.image = self.imageForStars(numberOfStars: nativeAd.starRating?.doubleValue ?? 0.0)
            gadNativeAdView?.starRatingView?.isHidden = (nativeAd.starRating == nil)

            (gadNativeAdView?.storeView as? UILabel)?.text = nativeAd.store
            gadNativeAdView?.storeView?.isHidden = ((nativeAd.store ?? "").count == 0)

            (gadNativeAdView?.priceView as? UILabel)?.text = nativeAd.price
            gadNativeAdView?.priceView?.isHidden = ((nativeAd.price ?? "").count == 0)

            (gadNativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
            gadNativeAdView?.advertiserView?.isHidden = ((nativeAd.advertiser ?? "").count == 0)

            // In order for the SDK to process touch events properly, user interaction
            // should be disabled.
            gadNativeAdView?.callToActionView?.isUserInteractionEnabled = false

            // Associate the native ad view with the native ad object. This is
            // required to make the ad clickable.
            // Note: this should always be done after populating the ad views.
            gadNativeAdView?.nativeAd = nativeAd
        }
    }

    // Show custom native ad
    func showCustomNativeAd(customNativeAd: GADCustomNativeAd) {
        // Add new ad view and set constraints to fill its container.
        // Create and place ad in view hierarchy.
        let customNativeAdView = Bundle.main.loadNibNamed("CustomNativeAdView", owner: nil, options: nil)?.first as? CustomNativeAdView
        if customNativeAdView != nil {
            nativeAdView = customNativeAdView
            customNativeAdView!.populateCustomNativeAdView(aCustomNativeAd: customNativeAd)
        }
    }

    // Gets an image representing the number of stars.
    func imageForStars(numberOfStars: Double) -> UIImage? {
        var imageName = "star_0"
        if numberOfStars >= 5 {
            imageName = "star_5"
        } else if numberOfStars > 4 {
            imageName = "star_4"
        } else if numberOfStars > 3 {
            imageName = "star_3"
        } else if numberOfStars > 2 {
            imageName = "star_2"
        } else if numberOfStars > 1 {
            imageName = "star_1"
        }

        return UIImage(named: imageName)
    }
}

// MARK: - Native Ad delegates
extension NativeAndBannerAdLoader {

    // MARK: POBGAMNativeAdDelegate
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func eventHandler(_ eventHandler: POBBannerEvent, didReceive nativeAd: GADNativeAd) {
        adLoadState = true

        // Set GAM native ad delegate
        nativeAd.delegate = self

        // Show native ad
        showNativeAd(nativeAd: nativeAd)

        // Notify native ad is received
        delegate?.nativeBannerAdLoaderDidReceiveNativeAd(adLoader: self)
    }

    // MARK: GADNativeAdDelegate
    // Called when an impression is recorded for an ad. Only called for Google ads and is not
    // supported for mediated ads.
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("Native : Ad recorded impression.")
    }

    // Called when a click is recorded for an ad. Only called for Google ads and is not
    // supported for mediated ads.
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("Native : Ad recorded click.")
    }
}

// MARK: - Custom Native Ad delegates
extension NativeAndBannerAdLoader {

    // MARK: POBGAMCustomNativeAdDelegate
    func customNativeAdFormatIDs() -> [String] {
        return ["12051535"]
    }

    func eventHandler(_ eventHandler: POBBannerEvent, didReceive customNativeAd: GADCustomNativeAd) {
       adLoadState = true
        // Set GAM custom native ad delegate
        customNativeAd.delegate = self

        // Show custom native ad
        showCustomNativeAd(customNativeAd: customNativeAd)

        // Record impression
        customNativeAd.recordImpression()

        // Notify custom native ad is received
        delegate?.nativeBannerAdLoaderDidReceiveCustomNativeAd(adLoader: self)
    }

    // MARK: GADCustomNativeAdDelegate
    func customNativeAdDidRecordImpression(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad recorded impression.")
    }

    func customNativeAdDidRecordClick(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad recorded click.")
    }
}
