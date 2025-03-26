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

class NativeStandardViewController: BaseViewController, POBNativeAdLoaderDelegate, POBNativeAdDelegate {

    @IBOutlet weak var renderAdButton: UIButton!
    let owAdUnit = "OpenWrapNativeAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    
    var nativeAdLoader: POBNativeAdLoader?
    var nativeAd: POBNativeAd?
    var nativeAdView: POBNativeAdView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the Native Ad Loader with desired template type (in this case, small).
        // For test IDs refer -
        // https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-3#test-profileplacements
        self.nativeAdLoader = POBNativeAdLoader(
            publisherId: pubId,
            profileId: profileId,
            adUnitId: owAdUnit,
            templateType: POBNativeTemplateType.small)

        // Set the delegate.
        self.nativeAdLoader?.delegate = self
    }
    
    deinit {
        nativeAdView = nil
        nativeAd = nil
        nativeAdLoader = nil
    }

    // MARK: UI Button actions

    @IBAction func loadAdButtonAction(_ sender: Any) {
        // Close previously shown native ad if any
        closeNativeAd()
        renderAdButton.isEnabled = false

        nativeAdLoader?.loadAd()
    }

    @IBAction func renderAdButtonAction(_ sender: Any) {
        // Render the native ad.
        self.nativeAd?.renderAd(completion: { [weak self] (nativeAd: POBNativeAd, error: Error?) in
            guard let self = self else {
                return
            }
            if let error = error {
                log("Native : Failed to render ad with error - \(error.localizedDescription)")
            } else {
                // Attach native ad view.
                self.nativeAdView = nativeAd.adView()
                self.addNativeAdViewToView(nativeAdView: self.nativeAdView, adSize: self.nativeAdView?.frame.size)
                log("Native : Ad rendered.")
            }
        })
    }

    // MARK: - POBNativeAdLoaderDelegate

    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didReceive nativeAd: POBNativeAd) {
        log("Native : Ad received.")
        self.nativeAd = nativeAd
        // Set the native ad delegate.
        self.nativeAd?.setAdDelegate(self)
        renderAdButton.isEnabled = true
    }
    
    // Notifies the delegate of an error encountered while loading an ad.
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didFailToReceiveAdWithError error: Error) {
        log("Native : Failed to receive ad with error - \(error.localizedDescription)")
    }
    
    // Returns a view controller instance to be used by ad server SDK for showing modals.
    func viewControllerForPresentingModal() -> UIViewController {
        return self
    }
    
    // MARK: - POBNativeAdDelegate
    
    // Informs delegate that the native ad has recorded a click.
    func nativeAdDidRecordClick(_ nativeAd: POBNativeAd) {
        log("Native : Ad click.")
    }
    
    // Notifies delegate that the native ad has dismissed the modal on top of the current view controller.
    func nativeAdDidDismissModal(_ nativeAd: POBNativeAd) {
        log("Native : Dismissed modal")
    }
    
    // Notifies delegate that the native ad will launch a modal on top of the current view controller, as a result of user interaction.
    func nativeAdWillPresentModal(_ nativeAd: POBNativeAd) {
        log("Native : Will present modal")
    }
    
    // Notifies delegate that the native ad have launched a modal on top of the current view controller, as a result of user interaction.
    func nativeAdDidPresentModal(_ nativeAd: POBNativeAd) {
        log("Native : Did present modal")
    }
    
    // Informs delegate that the native ad has recorded an impression.
    func nativeAdDidRecordImpression(_ nativeAd: POBNativeAd) {
        log("Native : Recorded impression.")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click.
    func nativeAdWillLeaveApplication(_ nativeAd: POBNativeAd) {
        log("Native : Will leave application")
    }
    
    // Informs delegate that the native ad has recorded a click for a particular asset.
    func nativeAd(_ nativeAd: POBNativeAd, didRecordClickForAsset assetId: Int) {
        log("Native : Recorded click for asset with Id: \(assetId)")
    }
    
    // MARK: - Supporting Methods
    
    private func addNativeAdViewToView(nativeAdView: POBNativeAdView?, adSize: CGSize?) {
        if let nativeAdView = nativeAdView, let adSize = adSize {
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nativeAdView)

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

    private func closeNativeAd() {
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
        nativeAd = nil
    }
}
