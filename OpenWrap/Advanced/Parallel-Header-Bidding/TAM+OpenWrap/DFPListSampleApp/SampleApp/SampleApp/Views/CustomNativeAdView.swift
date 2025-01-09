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

/**
 Custom view class created to render GAM's custom native ads as per format ID 12051535.
 */
class CustomNativeAdView: UIView {

    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var clickThroughButton: UIButton!
    @IBOutlet var mainImageView: UIImageView!
    private var customNativeAd: GADCustomNativeAd?

    // MARK: - Load methods
    override func awakeFromNib() {
        super.awakeFromNib()

        // Enable clicks on the title.
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performClickOnTitle)))
        titleLabel.isUserInteractionEnabled = true

        // Enable clicks on the icon.
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performClickOnIcon)))
        iconView.isUserInteractionEnabled = true

        // Enable clicks on the main image.
        mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performClickOnMainImage)))
        mainImageView.isUserInteractionEnabled = true
    }

    // MARK: - Click Actions
    @objc func performClickOnTitle() {
        guard let uCustomNativeAd = customNativeAd else { return }
        uCustomNativeAd.performClickOnAsset(withKey: "Title")
    }

    @objc func performClickOnIcon() {
        guard let uCustomNativeAd = customNativeAd else { return }
        uCustomNativeAd.performClickOnAsset(withKey: "Icon")
    }

    @objc func performClickOnMainImage() {
        guard let uCustomNativeAd = customNativeAd else { return }
        uCustomNativeAd.performClickOnAsset(withKey: "MainImage")
    }

    @IBAction func performClickOnClickThroughButton() {
        guard let uCustomNativeAd = customNativeAd else { return }
        uCustomNativeAd.performClickOnAsset(withKey: "ClickThroughText")
    }

    // MARK: - Public API
    func populateCustomNativeAdView(aCustomNativeAd: GADCustomNativeAd?) {
        guard let uCustomNativeAd = aCustomNativeAd else { return }
        customNativeAd = uCustomNativeAd

        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        titleLabel.text = uCustomNativeAd.string(forKey: "Title")

        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        let description = uCustomNativeAd.string(forKey: "description") ?? ""
        descriptionLabel.text = description
        descriptionLabel.isHidden = (description.count == 0)

        let clickThroughText = uCustomNativeAd.string(forKey: "ClickThroughText") ?? ""
        clickThroughButton.setTitle(clickThroughText, for: .normal)
        clickThroughButton.isHidden = (clickThroughText.count == 0)

        if let iconImg = uCustomNativeAd.image(forKey: "Icon")?.image {
            iconView.image = iconImg
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        if let mainImg = uCustomNativeAd.image(forKey: "MainImage")?.image {
            mainImageView.image = mainImg
            mainImageView.isHidden = false
        } else {
            mainImageView.isHidden = true
        }
    }
}
