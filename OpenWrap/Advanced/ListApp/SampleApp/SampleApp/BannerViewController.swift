/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2023 PubMatic, All Rights Reserved.
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

let OW_ADUNIT_ID         = "OpenWrapBannerAdUnit"
let PUB_ID               = "156276"
let PROFILE_ID: NSNumber = 1757

class BannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, POBBannerViewDelegate {
    
    @IBOutlet weak var adTableView: UITableView!
    var dataSource      = [AnyObject]()
    var adLoadState     = [POBBannerView: Bool]()
    var prefetchAdState = [POBBannerView: Bool]()
    var adsToLoad       = [POBBannerView]()
    var adCells         = [POBBannerView: UITableViewCell]()

    // Constants
    // Ad will be shown in every n'th cell in the table view, where n = adRecurrence
    let adRecurrence = 19
    let bannerAdSize:POBAdSize = POBAdSizeMake(300, 250)!
    // Don't change. This will be set to (bannerAdHeight + 10)
    var adCellHeight:CGFloat = 0.0

    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        adCellHeight = bannerAdSize.height() + 10
        // Do any additional setup after loading the view, typically from a nib.
        adTableView.rowHeight = UITableView.automaticDimension
        adTableView.estimatedRowHeight = adCellHeight
        adTableView.delegate = self;
        adTableView.dataSource = self;
        loadDataSource()
        preloadNextAd()
        OpenWrapSDK.setLogLevel(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("%@", "warning received")
    }
}

// MARK: - Helper methods
extension BannerViewController {
    func loadDataSource() {
        var adIndex = adRecurrence - 1
        // Load 200 rows
        for index in 0...200{
            if index == adIndex{
                
                // Create a banner view
                // For test IDs refer OpenWrap community document.
                let bannerView = POBBannerView(publisherId: PUB_ID, profileId: PROFILE_ID, adUnitId: OW_ADUNIT_ID, adSizes:[bannerAdSize])
                
                // Set the delegate
                bannerView?.delegate = self

                // Add the banner view to your view hierarchy
                bannerView?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: bannerAdSize.cgSize())
                bannerView?.center = CGPoint(x: view.bounds.width / 2, y: (bannerView?.center.y)!)
                
                if let ubannerView = bannerView {
                    adLoadState[ubannerView] = false
                    prefetchAdState[ubannerView] = false
                    dataSource.append(ubannerView)
                    adsToLoad.append(ubannerView)
                    adIndex += adRecurrence
                }
            }else {
                dataSource.append(String.init(format: "DataCell: %ld", index) as AnyObject)
            }
        }
    }
    
    // Use this function in case you want to preload banner ads, instead of loading when the cell becomes visible
    func preloadNextAd() {
        if !adsToLoad.isEmpty {
            let ad = adsToLoad.removeFirst()
            // Load Ad
            ad.loadAd()
        }
    }
}

// MARK: - UITableViewDataSource
extension BannerViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let bannerObject = dataSource[indexPath.row] as? POBBannerView{
            // Ad cell
            let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath)
            // Remove the previous ad, if any
            for aView in adCell.contentView.subviews{
                aView.removeFromSuperview()
            }
            // Add the banner view to this cell
            adCell.contentView.addSubview(bannerObject)
            bannerObject.center = adCell.contentView.center
            // Save the banner view - ad cell association in a map; to reload the cell with appropriate height, once the ad is loaded.
            adCells[bannerObject] = adCell
            // Request an ad if it's not loaded already for this cell
            if prefetchAdState[bannerObject] == false{
                preloadNextAd()
            }
            prefetchAdState[bannerObject] = true
            bannerObject.tag = indexPath.row
            return adCell
        } else {
            //Data cell
            let dataObject = dataSource[indexPath.row] as? String
            let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
            dataCell.textLabel?.text = dataObject
            return dataCell
        }
    }
}

// MARK: - UITableViewDelegate
extension BannerViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let tableItem = dataSource[indexPath.row] as? POBBannerView {
            let isAdLoaded = adLoadState[tableItem]
            return isAdLoaded == true ? adCellHeight : 0
        }
        return UITableView.automaticDimension
    }
}

// MARK: - POBBannerViewDelegate
extension BannerViewController {
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Ad received with size \(String(describing: bannerView.creativeSize())) ")
        
        if adLoadState[bannerView] == false {
            // Set load state of the banner view to true
            adLoadState[bannerView] = true
        }
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ wrapperBannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        print("Failed to load Ad with error : \(error.localizedDescription )")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        print("Banner view will leave Application")
    }
    
    // Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        print("Banner view will present modal")
    }
    
    // Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        print("Banner view dismissed modal")
    }
    
    // Notifies the delegate that the banner view was clicked.
    func bannerViewDidClickAd(_ bannerView: POBBannerView) {
        print("Banner : Ad clicked")
    }
}


