/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2019 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of
 * PubMatic. The intellectual and technical concepts contained herein are
 * proprietary to PubMatic and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from PubMatic.
 * Access to the source code contained herein is hereby forbidden to anyone
 * except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such
 * access.
 *
 * The copyright notice above does not evidence any actual or intended
 * publication or disclosure  of  this source code, which includes information
 * that is confidential and/or proprietary, and is a trade secret, of  PubMatic.
 * ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC
 * DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN
 * CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE
 * CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS TO
 * REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR
 * SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

import UIKit

/*!
 This class is responsible for communication between OpenBid banner view and Mopub banner view.
 It implements the POBBannerEvent protocol. it notifies event back to OpenBid SDK using POBBannerEventDelegate methods
 */
class MoPubBannerEventHandler: NSObject,POBBannerEvent,MPAdViewDelegate {
    
    /*!
     A configureBlock that is called before event handler makes ad request call to DFP SDK. It passes DFPBannerView & DFPRequest which will be used to make ad request.
     */
    var configBlock: ((_ view: MPAdView)->Void)?

    var bannerView:MPAdView?
    weak var _delegate: POBBannerEventDelegate?
    var contentSize:CGSize?
    var adSize:CGSize!

    /*!
     Initializes and returns a event handler with the specified Mopub ad unit and ad sizes
     
     @param adUnitId Mopub ad unit id
     @param size ad size
     */
    init(adUnitId:String, size:CGSize) {
        super.init()
        adSize = size
        bannerView = MPAdView(adUnitId: adUnitId, size: size)
        
        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        bannerView?.delegate = self
        
        // Disable MPAdView refresh, refresh will be managed by OpenBid SDK.
        bannerView?.stopAutomaticallyRefreshingContents()
    }
    
    deinit {
        bannerView?.delegate = nil
        bannerView = nil
        _delegate = nil
    }

// MARK: - POBBannerEvent delegates
    func requestAd(with bid: POBBid?) {
        
        bannerView?.keywords = nil;
        
        if !(bannerView?.delegate is MoPubBannerEventHandler) {
            NSLog("Do not set Mopub delegate. These are used by MoPubBannerEventHandler internally.");
        }

        // If bid is valid, add bid related keywords on Mopub view
        if bid != nil {
            if (configBlock != nil) {
                configBlock!(bannerView!)
            }

            let keywords = self.keywords(for: bid)
            bannerView?.keywords = keywords
            
            print("MoPub banner keywords: \(String(describing: keywords))")

            if (bid?.status != 0) {
                var localExtras = bannerView?.localExtras ?? [AnyHashable:Any]()
                localExtras["pob_bid"] = bid
                bannerView?.localExtras = localExtras
            }
        }
        bannerView?.loadAd()
    }
    
    func setDelegate(_ delegate: POBBannerEventDelegate!) {
        _delegate = delegate
    }
    
    func adContentSize() -> CGSize {
        return contentSize ?? CGSize.zero
    }
    
    func requestedAdSizes() -> [POBAdSize] {
        return [POBAdSize(cgSize: adSize)]
    }

// MARK: - MPAdViewDelegate
    func viewControllerForPresentingModalView() -> UIViewController! {
        return _delegate?.viewControllerForPresentingModal()
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        contentSize = view.adContentViewSize()
        _delegate?.adServerDidWin(view)
    }
    
    func adViewDidFail(toLoadAd view: MPAdView!) {
        let failureMsg = NSLocalizedString("MoPub ad server failed to load ad", comment: "")
        let userInfo = [NSLocalizedDescriptionKey: failureMsg,
                        NSLocalizedFailureReasonErrorKey: failureMsg]
        let eventError = NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorNoAds.rawValue, userInfo: userInfo)
        _delegate?.failedWithError(eventError)
    }
    
    func willPresentModalView(forAd view: MPAdView!) {
        _delegate?.willPresentModal()
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        _delegate?.didDismissModal()
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        _delegate?.willLeaveApp()
    }
    
    func keywords(for bid: POBBid?) -> String? {
        var keywords = ""
        let targetingInfo = bid?.targetingInfo()
        
        for key in (targetingInfo?.keys)! {
            keywords += String(format: "%@:%@,", key as! String,targetingInfo?[key] as! String)
        }
        if ((bannerView?.keywords?.count) != nil) {
            keywords += bannerView?.keywords ?? ""
        }else{
            if keywords.count != 0 {
                if let subRange = Range<String.Index>(NSRange(location: keywords.count - 1, length: 1), in: keywords) { keywords.removeSubrange(subRange) }
            }
        }
        return keywords
    }

}
