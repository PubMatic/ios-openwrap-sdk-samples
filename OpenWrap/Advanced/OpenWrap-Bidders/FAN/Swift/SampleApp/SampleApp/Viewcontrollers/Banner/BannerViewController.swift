/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2020 PubMatic, All Rights Reserved.
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

class BannerViewController: UIViewController,POBBannerViewDelegate {

    let owAdUnit = "OpenWrapBannerAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    
    let fb_appID = "2526468451010379"
    let fb_placementID = "2526468451010379_2526476071009617"

    var bannerView: POBBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a banner view
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
        self.bannerView = POBBannerView(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, adSizes: [POBAdSizeMake(320, 50)])
        // Set the delegate
        self.bannerView?.delegate = self
        
        var custParams: [AnyHashable : Any] = [:]
        custParams[POBBidderKey_FB_App_Id] = fb_appID
        custParams[POBBidderKey_FB_PlacementId] = fb_placementID
        custParams[POBBidderKey_BannerAdSize] = POBAdSizeMake(320, 50)

        // Add bidder
        self.bannerView?.addBidderSlotInfo(custParams, forBidder: POBBidderIdFAN)
        
        self.bannerView?.request.testModeEnabled = true

        // Add the banner view to your view hierarchy
        addBannerToView(banner: self.bannerView!, adSize: CGSize(width: 320, height: 50))
        
        // Load Ad
        self.bannerView?.loadAd()
    }
    
    func addBannerToView(banner : POBBannerView?, adSize : CGSize) -> Void {
        
        banner?.frame = CGRect(x: (self.view.bounds.size.width - adSize.width)/2
            , y: self.view.bounds.size.height - adSize.height, width: adSize.width, height: adSize.height)
        banner?.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(banner!)
    }
    
    // MARK: - Banner view delegate methods
    //Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Banner : Ad received with size \(String(describing: bannerView.creativeSize())) ")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                           didFailToReceiveAdWithError error: Error?) {
        print("Banner : Ad failed with error : \(error?.localizedDescription ?? "")")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        print("Banner : Will leave app")
    }
    
    // Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        print("Banner : Will present modal")
    }
    // Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        print("Banner : Dismissed modal")
    }

    deinit {
        bannerView = nil
    }
}
