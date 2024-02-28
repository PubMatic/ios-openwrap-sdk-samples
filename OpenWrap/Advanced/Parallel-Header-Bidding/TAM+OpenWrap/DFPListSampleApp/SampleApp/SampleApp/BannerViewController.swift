/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2024 PubMatic, All Rights Reserved.
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
import OpenWrapSDK
import OpenWrapHandlerDFP

class BannerViewController: UIViewController, UITableViewDelegate,
                      UITableViewDataSource, UITableViewDataSourcePrefetching,
                      AdLoaderDelegate {
    @IBOutlet weak var adTableView: UITableView!
    var dataSource      = [Any]()
    var adsToLoad       = [AdLoader]()

    // Don't change. This will be set to (bannerAdHeight + 10)
    var adCellHeight: CGFloat = 0.0

    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        adCellHeight = AD_SIZE.size.height + 10

        adTableView.estimatedRowHeight = adCellHeight
        adTableView.delegate = self
        adTableView.dataSource = self
        adTableView.prefetchDataSource = self
        loadDataSource()
        preloadNextAd()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("%@", "warning received")
    }
}

// MARK: - Helper methods
extension BannerViewController {
    func loadDataSource() {
        var adIndex = AD_INTERVAL - 1
        // Load 100 rows
        for index in 0...MAXIMUM_FEEDS {
            if index == adIndex {
                // Create ad loader and call load() on it which will request bid from OpenWrap as well as TAM
                let adloader = AdLoader.init(profileId: PROFILE_ID,
                                             pubId: PUB_ID,
                                             owAdUnitId: OW_AD_UNIT,
                                             gamAdUnitId: DFP_AD_UNIT,
                                             slotId: SLOT_UUID,
                                             adSize: AD_SIZE)
                adloader.delegate = self
                dataSource.append(adloader)
                adsToLoad.append(adloader)
                adIndex += AD_INTERVAL
            } else {
                dataSource.append(String.init(format: "FeedItem: %ld", index) as AnyObject)
            }
        }
    }

    // Use this function in case you want to preload banner ads, instead of loading when the cell becomes visible
    func preloadNextAd() {
        if !adsToLoad.isEmpty {
            let ad = adsToLoad.removeFirst()
            ad.load()
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension BannerViewController {
    /**
     Instructs your prefetch data source object to begin preparing data for the cells at the supplied index paths.
     */
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let adloader = dataSource[indexPath.row] as? AdLoader {
                if adloader.prefetchAdState == false {
                    preloadNextAd()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension BannerViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let adloader = dataSource[indexPath.row]
        
        if let loader = adloader as? AdLoader {
            // Ad cell
            let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath)
            // Remove the previous ad, if any
            for aView in adCell.contentView.subviews {
                aView.removeFromSuperview()
            }
            // Add the banner view to this cell
            adCell.contentView.addSubview(loader.bannerView)
            loader.bannerView.tag = indexPath.row
            
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
        if let tableItem = dataSource[indexPath.row] as? AdLoader {
            let isAdLoaded = tableItem.adLoadState
            return isAdLoaded == true ? adCellHeight : 0
        }
        return UITableView.automaticDimension
    }
}


// MARK: - AdLoader Delegate
extension BannerViewController {
    func adLoaderDidReceiveAd(adLoader: AdLoader) {
        print("Ad received with size \(String(describing: adLoader.bannerView.creativeSize())) ")
        adLoader.bannerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: adLoader.bannerView.creativeSize().cgSize())
        adLoader.bannerView.center = CGPoint(x: view.bounds.width / 2, y: (adLoader.bannerView.center.y))
        let indexPath = IndexPath(item: adLoader.bannerView.tag, section: 0)
        if self.adTableView.indexPathsForVisibleRows?.contains(indexPath) != nil {
            self.adTableView.reloadData()
        }
    }
    
    func adDidFail(bannerView: POBBannerView, error: NSError) {
        print("Failed to load Ad with error: \(error.localizedDescription )")
    }
    
    func viewController() -> UIViewController {
        return self
    }
}
