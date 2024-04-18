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

import Foundation
import OpenWrapSDK

class NativeStandardCustomTemplateViewController : UIViewController, POBNativeAdLoaderDelegate, POBNativeAdDelegate {
    let owAdUnit = "OpenWrapNativeAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165

    var nativeAdLoader: POBNativeAdLoader?
    var nativeAd: POBNativeAd?
    var nativeAdView: POBNativeAdView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the Native Ad Loader with desired template type (in this case, medium).
        // For test IDs refer -
        // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        self.nativeAdLoader = POBNativeAdLoader(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, templateType: POBNativeTemplateType.medium)
        
        // Set the delegate.
        self.nativeAdLoader?.delegate = self
        
        // Load ad.
        self.nativeAdLoader?.loadAd()
    }
    
    deinit {
        nativeAdView = nil
        nativeAd = nil
        nativeAdLoader = nil
    }
    
    // MARK: - POBNativeAdLoaderDelegate
    
    // Notifies the delegate that an ad has been successfully loaded.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didReceive nativeAd: POBNativeAd) {
        print("Native : Ad received.")
        self.nativeAd = nativeAd
        // Set the native ad delegate.
        self.nativeAd?.setAdDelegate(self)
        
        // Get the custom template view. Please note, NativeAdCustomMediumTemplateView is created on app side.
        let nibView = Bundle.main.loadNibNamed("NativeAdCustomMediumTemplateView", owner: nil)?.first
        
        // For template type POBNativeTemplateType.small, use POBNativeAdSmallTemplateView class.
        // For template type POBNativeTemplateType.medium, use POBNativeAdMediumTemplateView class.
        guard let templateView = nibView as? POBNativeAdMediumTemplateView else {
            return
        }
        
        // Render the native ad with custom template view.
        self.nativeAd?.renderAd(with: templateView, andCompletion: { [weak self] (nativeAd: POBNativeAd, error: Error?) in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Native : Failed to render ad with error - \(error.localizedDescription)")
            }
            else {
                // Attach native ad view.
                self.nativeAdView = nativeAd.adView()
                self.addNativeAdViewToView(nativeAdView: self.nativeAdView, adSize: self.nativeAdView?.frame.size)
                print("Native : Ad rendered.")
            }
        })
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
    
    func addNativeAdViewToView(nativeAdView: POBNativeAdView?, adSize: CGSize?) {
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let nativeAdView = nativeAdView {
            view.addSubview(nativeAdView)
            
            if let adSize = adSize {
                nativeAdView.heightAnchor.constraint(equalToConstant: adSize.height).isActive = true
                nativeAdView.widthAnchor.constraint(equalToConstant: adSize.width).isActive = true
            }
            
            if #available(iOS 11.0, *) {
                let guide = self.view.safeAreaLayoutGuide
                nativeAdView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                nativeAdView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
            } else {
                let margins = self.view.layoutMarginsGuide
                nativeAdView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
                nativeAdView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
            }
        }
    }
}
