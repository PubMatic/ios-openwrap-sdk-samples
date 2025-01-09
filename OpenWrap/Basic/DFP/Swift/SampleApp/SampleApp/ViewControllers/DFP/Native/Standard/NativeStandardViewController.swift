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

import Foundation
import OpenWrapSDK
import OpenWrapHandlerDFP
import GoogleMobileAds

class NativeStandardViewController: UIViewController, POBNativeAdLoaderDelegate, POBNativeAdDelegate {
    let gamAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Native"
    let owAdUnit = "/15671365/pm_sdk/PMSDK-Demo-App-Native"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    let owFormatId = "12260425"
    let customFormatId = "12051535"

    var nativeAdLoader: POBNativeAdLoader?
    var nativeAd: POBNativeAd?
    var nativeAdView: UIView?
    @IBOutlet weak var renderAdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a native event handler for your ad server.
        // For example, The code below creates an event handler for GAM ad server.
        let eventHandler = GAMNativeEventHandler(
            adUnitId: gamAdUnit,
            adTypes: [GADAdLoaderAdType.native, GADAdLoaderAdType.customNative],
            options: nil,
            owFormatId: owFormatId)

        // Populate your native ad view and return it in the given rendering block.
        eventHandler.nativeRenderingBlock = {[weak self] (nativeAd: GADNativeAd) -> GADNativeAdView? in
            guard let self = self else {
                return nil
            }
            return self.prepareNativeAdView(nativeAd: nativeAd)
        }
        
        // Populate your custom native ad view and return it in the given rendering block.
        eventHandler.customNativeRenderingBlock = {[weak self] (customNativeAd: GADCustomNativeAd) -> UIView? in
            guard let self = self else {
                return nil
            }
            return self.prepareCustomNativeAdView(customNativeAd: customNativeAd)
        }
        
        // This step is optional and you can set your custom format ids here.
        eventHandler.formatIds = [customFormatId]
        
        // Create the Native Ad Loader with desired template type (in this case, small).
        // For test IDs refer -
        // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-1#test-profileplacements
        self.nativeAdLoader = POBNativeAdLoader(
            publisherId: pubId,
            profileId: profileId,
            adUnitId: owAdUnit,
            templateType: POBNativeTemplateType.small,
            eventHandler: eventHandler)
        
        // Set the delegate.
        self.nativeAdLoader?.delegate = self
    }
    
    deinit {
        nativeAdLoader = nil
        nativeAdView = nil
        nativeAd = nil
    }
    
    @IBAction func loadAdButtonAction(_ sender: Any) {
        // Close previously shown native ad if any
        closeNativeAd()
        renderAdButton.isEnabled = false
        nativeAdLoader?.loadAd()
    }

    @IBAction func renderAdButtonAction(_ sender: Any) {
        // Render the native ad.
        nativeAd?.renderAd(completion: { [weak self] (_: POBNativeAd, error: Error?) in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Native : Failed to render ad with error - \(error.localizedDescription)")
            } else {
                // Attach native ad view.
                self.nativeAdView = self.nativeAd?.adView()
                self.addNativeAdViewToView(nativeAdView: self.nativeAdView, adSize: self.nativeAdView?.frame.size)
                print("Native : Ad rendered.")
            }
        })
    }

    // MARK: - POBNativeAdLoaderDelegate

    // Notifies the delegate that an ad has been successfully loaded.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didReceive nativeAd: POBNativeAd) {
        print("Native : Ad received.")
        self.nativeAd = nativeAd
        // Set the native ad delegate.
        self.nativeAd?.setAdDelegate(self)
        renderAdButton.isEnabled = true
    }
    
    // Notifies the delegate of an error encountered while loading an ad.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native : Failed to receive ad with error - \(error.localizedDescription)")
    }
    
    // Returns a view controller instance to be used by ad server SDK for showing modals.
    func viewControllerForPresentingModal() -> UIViewController {
        return self
    }
    
    // MARK: - POBNativeAdDelegate
    
    // Informs delegate that the native ad has recorded a click.
    func nativeAdDidRecordClick(_ nativeAd: POBNativeAd) {
        print("Native : Ad click.")
    }
    
    // Notifies delegate that the native ad has dismissed the modal on top of the current view controller.
    func nativeAdDidDismissModal(_ nativeAd: POBNativeAd) {
        print("Native : Dismissed modal")
    }
    
    // Notifies delegate that the native ad will launch a modal on top of the current view controller, as a result of user interaction.
    func nativeAdWillPresentModal(_ nativeAd: POBNativeAd) {
        print("Native : Will present modal")
    }
    
    // Notifies delegate that the native ad have launched a modal on top of the current view controller, as a result of user interaction.
    func nativeAdDidPresentModal(_ nativeAd: POBNativeAd) {
        print("Native : Did present modal")
    }
    
    // Informs delegate that the native ad has recorded an impression.
    func nativeAdDidRecordImpression(_ nativeAd: POBNativeAd) {
        print("Native : Recorded impression.")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click.
    func nativeAdWillLeaveApplication(_ nativeAd: POBNativeAd) {
        print("Native : Will leave application")
    }
    
    // Informs delegate that the native ad has recorded a click for a particular asset.
    func nativeAd(_ nativeAd: POBNativeAd, didRecordClickForAsset assetId: Int) {
        print("Native : Recorded click for asset with Id: \(assetId)")
    }
    
    // MARK: - Supporting Methods
    
    private func addNativeAdViewToView(nativeAdView: UIView?, adSize: CGSize?) {
        if let nativeAdView = nativeAdView, let adSize = adSize {
            view.addSubview(nativeAdView)
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false

            // Decide layout guide based on available iOS version
            let layoutGuide: UILayoutGuide
            if #available(iOS 11.0, *) {
                layoutGuide = view.safeAreaLayoutGuide
            } else {
                layoutGuide = view.layoutMarginsGuide
            }

            NSLayoutConstraint.activate([
                nativeAdView.widthAnchor.constraint(equalToConstant: adSize.width),
                nativeAdView.heightAnchor.constraint(equalToConstant: adSize.height),
                nativeAdView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
                nativeAdView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
            ])
        }
    }
    
    private func prepareNativeAdView(nativeAd: GADNativeAd) -> GADNativeAdView? {
        // Create and place ad in view hierarchy.
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first
        guard let gadNativeAdView = nibView as? GADNativeAdView else {
            return nil
        }
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (gadNativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        gadNativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        if let mediaView = gadNativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint.isActive = true
        }
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (gadNativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        gadNativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (gadNativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        gadNativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (gadNativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        gadNativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (gadNativeAdView.starRatingView as? UIImageView)?.image = imageForStars(numberOfStars: nativeAd.starRating?.doubleValue ?? 0.0)
        gadNativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (gadNativeAdView.storeView as? UILabel)?.text = nativeAd.store
        gadNativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (gadNativeAdView.priceView as? UILabel)?.text = nativeAd.price
        gadNativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (gadNativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        gadNativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        gadNativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        gadNativeAdView.nativeAd = nativeAd
        
        return gadNativeAdView
    }
    
    private func prepareCustomNativeAdView(customNativeAd: GADCustomNativeAd) -> CustomNativeAdView? {
        // Add new ad view and set constraints to fill its container.
        // Create and place ad in view hierarchy.
        let nibView = Bundle.main.loadNibNamed("CustomNativeAdView", owner: nil, options: nil)?.first
        guard let gadCustomNativeAdView = nibView as? CustomNativeAdView else {
            return nil
        }
        
        gadCustomNativeAdView.populateCustomNativeAdView(aCustomNativeAd: customNativeAd)
        
        return gadCustomNativeAdView
    }
    
    private func imageForStars(numberOfStars: Double) -> UIImage? {
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

    private func closeNativeAd() {
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
        nativeAd = nil
    }
}
