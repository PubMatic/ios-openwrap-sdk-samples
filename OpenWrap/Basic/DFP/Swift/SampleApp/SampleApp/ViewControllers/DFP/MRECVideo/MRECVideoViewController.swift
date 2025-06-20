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
import OpenWrapHandlerDFP
import GoogleMobileAds

class MRECVideoViewController: BaseViewController, POBBannerViewDelegate {

    let dfpAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Banner"
    let owAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Banner"
    let pubId = "156276"
    let profileId: NSNumber = 1757

    var bannerView: POBBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let adSizes = [nsValue(for: AdSizeMediumRectangle)]
        
        // Create a banner custom event handler for your ad server. Make
        // sure you use separate event handler objects to create each interstitial
        // For example, The code below creates an event handler for DFP ad server.
        let eventHandler = DFPBannerEventHandler(adUnitId: dfpAdUnit, andSizes: adSizes)

        // Create a banner view
        // For test IDs refer -
        // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-1#test-profileplacements
        self.bannerView = POBBannerView(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler!)
        
        // Set the delegate
        self.bannerView?.delegate = self

        // Add the banner view to your view hierarchy
        addBannerToView(banner: self.bannerView!, adSize: AdSizeMediumRectangle.size)
        
        // Load Ad
        self.bannerView?.loadAd()
        
    }
    
    func addBannerToView(banner : POBBannerView?, adSize: CGSize) {
        
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        if let bannerView = bannerView {
            view.addSubview(bannerView)
        }

        bannerView?.heightAnchor.constraint(equalToConstant: adSize.height).isActive = true
        bannerView?.widthAnchor.constraint(equalToConstant: adSize.width).isActive = true

        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            bannerView?.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            bannerView?.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        } else {
            let margins = self.view.layoutMarginsGuide
            bannerView?.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
            bannerView?.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        }
    }

    // MARK: - Banner view delegate methods
    //Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        log("Banner : Ad received with size \(String(describing: bannerView.creativeSize())) ")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                    didFailToReceiveAdWithError error: Error) {
        log("Banner : Ad failed with error : \(error.localizedDescription )")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        log("Banner : Will leave app")
    }
    
    // Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
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

    func bannerViewDidRecordImpression(_ bannerView: POBBannerView) {
        log("Banner : Ad Impression")
    }

    deinit {
        bannerView = nil
    }
}

