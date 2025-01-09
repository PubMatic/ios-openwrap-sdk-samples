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

class BannerViewController: UIViewController,POBBannerViewDelegate,POBBidEventDelegate {

    let owAdUnit = "OpenWrapBannerAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    let isOWAuctionWin = true
    
    var bannerView: POBBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a banner view
        // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        self.bannerView = POBBannerView(
            publisherId: pubId,
            profileId: profileId,
            adUnitId: owAdUnit,
            adSizes: [POBAdSizeMake(320, 50)])
        
        // Set the delegate
        self.bannerView?.delegate = self
        
        // Set the bid event delegate
        self.bannerView?.bidEventDelegate = self

        // Add the banner view to your view hierarchy
        addBannerToView(banner: self.bannerView!, adSize: CGSize(width: 320, height: 50))
        
        // Load Ad
        self.bannerView?.loadAd()
    }

    deinit {
        bannerView = nil
    }

    // Function simulates auction
    func auctionAndProceedWithBid(bid:POBBid) {
        print("Banner : Proceeding with load ad.")
        // Check if bid is expired
        if !bid.isExpired() {
            // Use bid, e.g. perform auction with your in-house mediation setup
            // ..
            // Auction complete
            if isOWAuctionWin {
                // OW bid won in the auction
                // Call bannerView?.proceedToLoadAd() to complete the bid flow
                bannerView?.proceedToLoadAd()
            }else{
                // Notify banner to proceed with auction loss error.
                bannerView?.proceed(
                    onError: POBBidEventErrorCode.clientSideAuctionLoss,
                    andDescription: "Client Side Auction Loss")
            }
        } else {
            // Notify banner view to proceed with the error.
            bannerView?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }
    
    // MARK: - Bid event delegate methods
    // Notifies the delegate that bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid.
        print("Banner : Bid received.")
        // Notify banner view to proceed to load the ad after using the bid, e.g perform an auction
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify banner view to proceed with the error.
        print("Banner : Bid receive failed with error : \(error.localizedDescription)")
        bannerView?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: - Banner view delegate methods
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Banner : Ad received with size \(String(describing: bannerView.creativeSize())) ")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                    didFailToReceiveAdWithError error: Error) {
        print("Banner : Ad failed with error : \(error.localizedDescription )")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: POBBannerView) {
        print("Banner : Ad Impression")
    }

    // MARK: - Private functions

    private func addBannerToView(banner: POBBannerView, adSize: CGSize) {
        banner.frame = CGRect(
            x: (self.view.bounds.size.width - adSize.width)/2,
            y: self.view.bounds.size.height - adSize.height,
            width: adSize.width,
            height: adSize.height)

        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)

        // Decide layout guide based on available iOS version
        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }

        NSLayoutConstraint.activate([
            banner.widthAnchor.constraint(equalToConstant: adSize.width),
            banner.heightAnchor.constraint(equalToConstant: adSize.height),
            banner.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            banner.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        ])
    }
}
