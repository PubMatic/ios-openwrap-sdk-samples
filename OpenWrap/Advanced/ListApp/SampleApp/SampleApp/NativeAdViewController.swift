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

let OW_ADUNIT_ID_NATIVE         = "OpenWrapNativeAdUnit"
let PUB_ID_NATIVE               = "156276"
let PROFILE_ID_NATIVE: NSNumber = 1165
// Ads will be shown in every n'th cell in the table view, where n = adRecurrence
let adRecurrence = 5
// Total rows in this feed
let totalFeeds = 60

class FeedItem {
    var type:String
    var ad:POBNativeAd?
    
    init(type: String, ad: POBNativeAd? = nil) {
        self.type = type
        self.ad = ad
    }
}

class NativeAdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, POBNativeAdLoaderDelegate, POBNativeAdDelegate {
    
    @IBOutlet weak var adTableView: UITableView!
    // Data source for the feed
    var dataSource          = [FeedItem]()
    var adIndex = adRecurrence - 1
    var totalAds = totalFeeds/adRecurrence
    let adCellHeight: CGFloat = 260
    let nativeAdLoader = POBNativeAdLoader(publisherId: PUB_ID_NATIVE, profileId: PROFILE_ID_NATIVE, adUnitId: OW_ADUNIT_ID_NATIVE, templateType: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate
        adTableView.delegate = self
        adTableView.dataSource = self
        nativeAdLoader.delegate = self
        nativeAdLoader.request.adServerURL = "https://owsdk-stagingams.pubmatic.com:8443/sdk/php/sdkNative.php"
        let userInfo = POBUserInfo()
        userInfo.keywords = "atn:mediumwithrequiredparams_p:10.01"
        OpenWrapSDK.setUserInfo(userInfo)
        // Load the data source for the feed
        loadDataSource()
        // Prefetch ads one-by-one
        prefetchNextAd()
        OpenWrapSDK.setLogLevel(.all)
        OpenWrapSDK.setDSAComplianceStatus(.required)
    }
    
    override func didReceiveMemoryWarning() {
        print("%@", "Memory warning received")
    }
    
    // Load the data source for the feed
    func loadDataSource() {
        for i in 0...(totalFeeds - 1) {
            if (i + 1) % adRecurrence != 0 {
                dataSource.append(FeedItem(type: "Data"))
            } else {
                dataSource.append(FeedItem(type: "Ad"))
            }
        }
    }
        
    // Prefetch an ad
    func prefetchNextAd () {
        nativeAdLoader.loadAd()
    }
    
    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalFeeds
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row].type == "Ad" {
            // Ad cell
            let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath)
            // Remove the previous ad, if any
            for aView in adCell.contentView.subviews{
                aView.removeFromSuperview()
            }
            // Fetch a native ad for this cell
            let nativeAd = dataSource[indexPath.row].ad
            guard let nativeAdView = nativeAd?.adView() else {
                return adCell
            }
            // If the ad is available, show it
            adCell.contentView.addSubview(nativeAdView)
            nativeAdView.center = adCell.contentView.center
            return adCell
        } else {
            // Data cell
            return tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource[indexPath.row].type == "Ad" {
            // Hide the ad cell if the ad is not ready yet
            return dataSource[indexPath.row].ad != nil ? adCellHeight : 0
        }
        return adCellHeight
    }
    
    // MARK: NativeAdLoaderDelegate
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didReceive nativeAd: POBNativeAd) {
        print("Native : Ad Received")
        // Update the data source & save the ad
        dataSource[adIndex].ad = nativeAd
        // Load next ad
        if adIndex < totalFeeds - 1 {
            prefetchNextAd()
            adIndex += adRecurrence
        }
        nativeAd.setAdDelegate(self)
        // Render ad - prepares a pre-rendered native ad view
        nativeAd.renderAd(completion: { (_, error) in
            if error != nil {
                print("Native: Ad failed to show with error - POBError{errorMessage='%@'}", error?.localizedDescription as Any)
            } else {
                print("Native: Ad rendered")
            }
        })
    }
    
    func nativeAdLoader(_ adLoader: POBNativeAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native : Failed to load with error - POBError{errorMessage='%@'}", error.localizedDescription)
    }
    
    func viewControllerForPresentingModal() -> UIViewController {
        return self
    }
    
    // MARK: NativeAdDelegate
    func nativeAdDidDismissModal(_ nativeAd: POBNativeAd) {
        print("Native : Dismissed modal")
    }
    
    func nativeAdWillPresentModal(_ nativeAd: POBNativeAd) {
        print("Native : Will present modal")
    }
    
    func nativeAdDidPresentModal(_ nativeAd: POBNativeAd) {
        print("Native : Did present modal")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: POBNativeAd) {
        print("Native : App Leaving")
    }
    
    func nativeAdDidRecordClick(_ nativeAd: POBNativeAd) {
        print("Native : Ad recorded clicked")
    }
    
    func nativeAd(_ nativeAd: POBNativeAd, didRecordClickForAsset assetId: Int) {
        print("Native : Ad recorded clicked for asset Id- %d", assetId)
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: POBNativeAd) {
        print("Native : Ad recorded impression")
    }
}
