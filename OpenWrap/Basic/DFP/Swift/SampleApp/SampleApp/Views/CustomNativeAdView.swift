//
//  CustomNativeAdView.swift
//  SampleApp
//
//  Created by Preety on 01/09/21.
//  Copyright © 2021 PubMatic. All rights reserved.
//

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
        descriptionLabel.text = description;
        descriptionLabel.isHidden = (description.count == 0)
        
        let clickThroughText = uCustomNativeAd.string(forKey: "ClickThroughText") ?? ""
        clickThroughButton.setTitle(clickThroughText, for: .normal)
        clickThroughButton.isHidden = (clickThroughText.count == 0)
        
        if let iconImg = uCustomNativeAd.image(forKey: "Icon")?.image {
            iconView.image = iconImg;
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        
        if let mainImg = uCustomNativeAd.image(forKey: "MainImage")?.image {
            mainImageView.image = mainImg;
            mainImageView.isHidden = false
        } else {
            mainImageView.isHidden = true
        }
    }
}
