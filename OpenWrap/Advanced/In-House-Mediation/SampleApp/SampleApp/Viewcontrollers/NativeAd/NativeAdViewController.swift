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

class NativeAdViewController: BaseViewController,
                              POBNativeAdLoaderDelegate,
                              POBNativeAdDelegate,
                              POBBidEventDelegate {
    @IBOutlet weak var renderAdButton: UIButton!
    private let isOWAuctionWin = true

    private static let owAdUnitId  = "OpenWrapNativeAdUnit"
    private static let pubId = "156276"
    private static let profileId: NSNumber = 1165

    private var nativeAd: POBNativeAd?
    private var nativeAdView: POBNativeAdView?
    private var bidEventObject: POBBidEvent?
    private lazy var nativeAdLoader: POBNativeAdLoader? = POBNativeAdLoader(
        publisherId: Self.pubId,
        profileId: Self.profileId,
        adUnitId: Self.owAdUnitId,
        templateType: .small)

    override func viewDidLoad() {
        super.viewDidLoad()

        nativeAdLoader?.delegate = self
        nativeAdLoader?.bidEventDelegate = self
    }

    deinit {
        nativeAdLoader?.delegate = nil
        nativeAdLoader?.bidEventDelegate = nil
        nativeAdLoader = nil
        nativeAd = nil
        nativeAdView = nil
    }

    // MARK: UI Button actions

    @IBAction func loadAdButtonAction(_ sender: UIButton) {
        // Close previously shown native ad if any
        closeNativeAd()
        renderAdButton.isEnabled = false
        nativeAdLoader?.loadAd()
    }

    @IBAction func renderAdButtonAction(_ sender: UIButton) {
        nativeAd?.renderAd(completion: { [weak self] (nativeAd: POBNativeAd, error: Error?) in
            guard let self else { return }
            if let error {
                log("Native Ad : Failed to render ad with error : \(error.localizedDescription)")
                return
            }
            let adView = nativeAd.adView()
            nativeAdView = adView
            addNativeAdToView(adView: adView, adSize: adView.bounds.size)
            log("Native Ad : Ad rendered.")
        })
    }

    // MARK: POBNativeAdLoaderDelegate

    /// Called when presenting a modal on user interaction with native ad.
    func viewControllerForPresentingModal() -> UIViewController {
        return self
    }

    /// Called when the native ad is received.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didReceive nativeAd: POBNativeAd) {
        log("Native Ad : Ad Received")
        self.nativeAd = nativeAd
        // Set native ad delegate
        self.nativeAd?.setAdDelegate(self)
        renderAdButton.isEnabled = true
    }

    /// Called when the native ad is failed to received.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didFailToReceiveAdWithError error: Error) {
        log("Native Ad : Failed to receive ad with error : \(error.localizedDescription)")
    }

    // MARK: POBBidEventDelegate

    /// Called when the bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid,  e.g. perform auction with your setup
        log("Native Ad : Bid received")
        self.bidEventObject = bidEventObject
        // Notify rewarded to proceed to load the ad after using the bid.
        auctionAndProceedWithBid(bid)
    }

    /// Called when an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify native ad to proceed on the error.
        log("Native Ad : Bid receive failed with error : \(error.localizedDescription)")
        bidEventObject.proceed(onError: .other, andDescription: error.localizedDescription)
    }

    // MARK: POBNativeAdDelegate

    /// Called when the native ad is about to launch a modal on top of the current view controller,
    /// as a result of user interaction.
    func nativeAdWillPresentModal(_ nativeAd: POBNativeAd) {
        log("Native Ad : Will present modal")
    }

    /// Called when the native ad has launched a modal on top of the current view controller,
    /// as a result of user interaction.
    func nativeAdDidPresentModal(_ nativeAd: POBNativeAd) {
        log("Native Ad : Did present modal")
    }

    /// Called when the native ad has dismissed the modal on top of the current view controller.
    func nativeAdDidDismissModal(_ nativeAd: POBNativeAd) {
        log("Native Ad : Did dismiss modal")
    }

    /// Called when the current app goes in the background due to user click.
    func nativeAdWillLeaveApplication(_ nativeAd: POBNativeAd) {
        log("Native Ad : Will leave application")
    }

    /// Called when the native ad has recorded a click.
    func nativeAdDidRecordClick(_ nativeAd: POBNativeAd) {
        log("Native Ad : Ad click")
    }

    /// Called when the native ad has recorded a click for a particular asset.
    func nativeAd(_ nativeAd: POBNativeAd, didRecordClickForAsset assetId: Int) {
        log("Native Ad : Recorded click for asset with Id: \(assetId)")
    }

    /// Called when the native ad has recorded an impression
    func nativeAdDidRecordImpression(_ nativeAd: POBNativeAd) {
        log("Native Ad : Ad recorded impression")
    }

    // MARK: Private helper methods

    // Function simulates auction
    private func auctionAndProceedWithBid(_ bid: POBBid) {
        log("Native Ad : Proceeding with load ad.")
        // Check if bid is expired
        if !bid.isExpired() {
            // Use bid, e.g. perform auction with your in-house mediation setup
            // ..
            // Auction complete
            if isOWAuctionWin {
                // OW bid won in the auction
                // Call bidEventObject?.proceedToLoadAd() to complete the bid flow
                bidEventObject?.proceedToLoadAd()
            } else {
                // Notify native ad to proceed with auction loss error.
                bidEventObject?.proceed(
                    onError: POBBidEventErrorCode.clientSideAuctionLoss,
                    andDescription: "Client Side Auction Loss")
            }
        } else {
            // Notify native ad to proceed with expiry error.
            bidEventObject?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }

    private func closeNativeAd() {
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
        nativeAd = nil
    }

    private func addNativeAdToView(adView: POBNativeAdView, adSize: CGSize) {
        adView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adView)

        // Decide layout guide based on available iOS version
        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }

        NSLayoutConstraint.activate([
            adView.widthAnchor.constraint(equalToConstant: adSize.width),
            adView.heightAnchor.constraint(equalToConstant: adSize.height),
            adView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            adView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        ])
    }
}
