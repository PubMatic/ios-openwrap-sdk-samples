/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2024 PubMatic, All Rights Reserved.
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

class NativeAndBannerViewController: UIViewController, POBBannerViewDelegate, POBGAMNativeAdDelegate, POBGAMCustomNativeAdDelegate, GADNativeAdDelegate, GADCustomNativeAdDelegate {

    let gamAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-NativeAndBanner"
    let owAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-NativeAndBanner"
    let pubId = "156276"
    let profileId: NSNumber = 1165

    /// OpenWrap banner view
    var bannerView: POBBannerView?
    /// The native or custom native ad view that is being presented.
    var nativeAdView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let adSizes = [NSValueFromGADAdSize(GADAdSizeMediumRectangle)]
        
        // Create a native banner event handler for your ad server. Make
        // sure you use separate event handler objects to create each banner
        // For example, The code below creates an event handler for GAM ad server.
        let eventHandler = GAMNativeBannerEventHandler(adUnitId: gamAdUnit, adTypes: [GADAdLoaderAdType.native, GADAdLoaderAdType.customNative], options: nil, andSizes: adSizes)
        
        // Set event handler delegate for native ad
        eventHandler.nativeDelegate = self
        
        // Set event handler delegate for custom native ad
        eventHandler.customNativeDelegate = self
        
        // Create a banner view
        // For test IDs refer - https://community.pubmatic.com/display/IDFP/Test+and+debug+your+integration
        self.bannerView = POBBannerView(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler)
        
        // Set the delegate
        self.bannerView?.delegate = self

        // Load Ad
        self.bannerView?.loadAd()
    }

    // MARK: - Banner view delegate methods
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Banner : Ad received with size \(String(describing:bannerView.creativeSize())) ")

        // Add the banner view to your view hierarchy.
        // You may also add it after an ad is successfully loaded.
        addBannerToView(banner: self.bannerView!, adSize: bannerView.creativeSize().cgSize())
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                    didFailToReceiveAdWithError error: Error) {
        print("Banner : Ad failed with error : \(error.localizedDescription )")
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
    
    // Notifies the delegate that the banner view was clicked.
    func bannerViewDidClickAd(_ bannerView: POBBannerView) {
        print("Banner : Ad clicked")
    }

    // MARK: - POBGAMNativeAdDelegate
    // Notifies the delegate that an ad has been successfully received.
    func eventHandler(_ eventHandler: POBBannerEvent, didReceive nativeAd: GADNativeAd) {
        print("Native : Ad received.")
        
        // Set GAM native ad delegate
        nativeAd.delegate = self
        
        // Show native ad
        self.showNativeAd(nativeAd: nativeAd)
    }
    
    // MARK: - POBGAMCustomNativeAdDelegate
    // Return an array of custom native ad format ID
    func customNativeAdFormatIDs() -> [String] {
        return ["12051535"]
    }
    
    // Notifies the delegate that an ad has been successfully received.
    func eventHandler(_ eventHandler: POBBannerEvent, didReceive customNativeAd: GADCustomNativeAd) {
        print("Custom Native : Ad received.")
        
        // Set GAM custom native ad delegate
        customNativeAd.delegate = self
        
        // Show custom native ad
        self.showCustomNativeAd(customNativeAd: customNativeAd)
        
        // Record impression
        customNativeAd.recordImpression()
    }
    
    // MARK: - GADNativeAdDelegate
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
    
    // Called before presenting the user a full screen view in response to an ad action
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("Native : Ad will present screen.")
    }
    
    // Called before dismissing a full screen view.
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("Native : Ad will dismiss screen.")
    }
    
    // Called after dismissing a full screen view
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("Native : Ad did dismiss screen.")
    }
    
    // Used for Mute This Ad feature. Called after the native ad is muted.
    func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        print("Native : Ad is muted.")
    }
    
    // MARK: - GADCustomNativeAdDelegate
    // Called when an impression is recorded for a custom native ad.
    func customNativeAdDidRecordImpression(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad recorded impression.")
    }
    
    // Called when a click is recorded for a custom native ad.
    func customNativeAdDidRecordClick(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad recorded click.")
    }
    
    // Called just before presenting the user a full screen view, such as a browser,
    // in response to clicking on an ad.
    func customNativeAdWillPresentScreen(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad will present screen.")
    }
    
    // Called just before dismissing a full screen view.
    func customNativeAdWillDismissScreen(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad will dismiss screen.")
    }
    
    // Called just after dismissing a full screen view.
    func customNativeAdDidDismissScreen(_ nativeAd: GADCustomNativeAd) {
        print("Custom native : Ad did dismiss screen.")
    }

    // MARK: - Helper methods
    // Show native ad
    func showNativeAd(nativeAd: GADNativeAd) -> Void {
        // Remove previous ad view.
        nativeAdView?.removeFromSuperview()
        
        // Add new ad view and set constraints to fill its container.
        // Create and place ad in view hierarchy.
        let gadNativeAdView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        if gadNativeAdView != nil {
            nativeAdView = gadNativeAdView!
            addBannerToView(banner: nativeAdView!, adSize: nativeAdView!.frame.size)
            
            // Populate the native ad view with the native ad assets.
            // The headline and mediaContent are guaranteed to be present in every native ad.
            (gadNativeAdView?.headlineView as! UILabel).text = nativeAd.headline
            
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
            (gadNativeAdView!.bodyView as! UILabel).text = nativeAd.body
            gadNativeAdView!.bodyView?.isHidden = ((nativeAd.body ?? "").count == 0)
            
            (gadNativeAdView!.callToActionView as! UIButton).setTitle(nativeAd.callToAction, for: .normal)
            gadNativeAdView!.callToActionView?.isHidden = ((nativeAd.callToAction ?? "").count == 0)
            
            (gadNativeAdView!.iconView as! UIImageView).image = nativeAd.icon?.image
            gadNativeAdView!.iconView?.isHidden = (nativeAd.icon == nil)
            
            (gadNativeAdView!.starRatingView as! UIImageView).image = self.imageForStars(numberOfStars: nativeAd.starRating?.doubleValue ?? 0.0)
            gadNativeAdView?.starRatingView?.isHidden = (nativeAd.starRating == nil)
            
            (gadNativeAdView?.storeView as! UILabel).text = nativeAd.store
            gadNativeAdView?.storeView?.isHidden = ((nativeAd.store ?? "").count == 0)
            
            (gadNativeAdView?.priceView as! UILabel).text = nativeAd.price
            gadNativeAdView?.priceView?.isHidden = ((nativeAd.price ?? "").count == 0)
            
            (gadNativeAdView?.advertiserView as! UILabel).text = nativeAd.advertiser
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
    func showCustomNativeAd(customNativeAd: GADCustomNativeAd) -> Void {
        // Remove previous ad view.
        nativeAdView?.removeFromSuperview()
        
        // Add new ad view and set constraints to fill its container.
        // Create and place ad in view hierarchy.
        let customNativeAdView = Bundle.main.loadNibNamed("CustomNativeAdView", owner: nil, options: nil)?.first as? CustomNativeAdView
        if customNativeAdView != nil {
            customNativeAdView!.populateCustomNativeAdView(aCustomNativeAd: customNativeAd)
            nativeAdView = customNativeAdView!
            addBannerToView(banner: nativeAdView!, adSize: nativeAdView!.frame.size)
        }
    }
    
    // Attach banner view to superview
    func addBannerToView(banner: UIView?, adSize: CGSize) {
        
        if let uBanner = banner {
            uBanner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(uBanner)
            
            uBanner.heightAnchor.constraint(equalToConstant: adSize.height).isActive = true
            uBanner.widthAnchor.constraint(equalToConstant: adSize.width).isActive = true

            if #available(iOS 11.0, *) {
                let guide = self.view.safeAreaLayoutGuide
                uBanner.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                uBanner.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
            } else {
                let margins = self.view.layoutMarginsGuide
                uBanner.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
                uBanner.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
            }
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
    
    deinit {
        bannerView = nil
    }
}
