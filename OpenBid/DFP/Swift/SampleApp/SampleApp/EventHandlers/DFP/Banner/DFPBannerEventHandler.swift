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
import GoogleMobileAds

class DFPBannerEventHandler: NSObject,POBBannerEvent,GADBannerViewDelegate,GADAppEventDelegate,GADAdSizeDelegate {

    let SYNC_TIMEOUT_INTEREVAL = 0.6
    
    var bannerView: DFPBannerView?
    var timer: Timer?
    weak var _delegate: POBBannerEventDelegate?
    var dfpAdSize = CGSize.zero
    var notified = false
    var isAppEventExpected = false
    var adSizes = [NSValue]()

    init(_ adUnitId: String, andSizes validSizes: [NSValue]) {
        super.init()
        bannerView = DFPBannerView()
        bannerView?.adUnitID = adUnitId
        
        adSizes = validSizes
        
        bannerView?.validAdSizes = validSizes
        dfpAdSize = (bannerView?.adSize.size)!
        
        bannerView?.delegate = self
        bannerView?.appEventDelegate = self
        bannerView?.adSizeDelegate = self
    }
    
    deinit {
        bannerView?.delegate = nil
        bannerView = nil
    }
    
    func setDelegate(_ delegate: POBBannerEventDelegate!) {
        _delegate = delegate
    }

    func requestAd(with bid: POBBid?) {
        
        notified = false
        isAppEventExpected = false
        bannerView?.rootViewController = _delegate?.viewControllerForPresentingModal()
        let dfpRequest = DFPRequest()
        if bid != nil {
            if bid?.status.boolValue ?? false {
                isAppEventExpected = true
            }
            dfpRequest.customTargeting = bid?.targetingInfo()
            print("Bid details : \(String(describing: bid?.targetingInfo().description))")
        }
        bannerView?.load(dfpRequest)
    }
    
    func adContentSize() -> CGSize {
        return dfpAdSize
    }
    
    func requestedAdSizes() -> [POBAdSize] {
        var sizes:[POBAdSize] = []
        for value in adSizes {
            let gAdSize = GADAdSizeFromNSValue(value)
            sizes.append(POBAdSize(cgSize: gAdSize.size))
        }
        return sizes
    }
    
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        if (name == "pubmaticdm") {
            if notified {
                var userInfo: [AnyHashable : Any]? = nil
                let errorMessage = "App event is called unexpetedly"
                userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(errorMessage, comment: "")]
                let error = NSError(domain: kPOBErrorDomain, code: POBErrorCode.signalingError.rawValue, userInfo: userInfo as? [String : Any])
                _delegate?.failedWithError(error)
                return
            }
            notified = true
            _delegate?.openBidPartnerDidWin()
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        // If already notifed, skip waiting for app event
        if notified {
            return
        }
        
        // If PubMatic have provided non-zero bir price, expect for app event for fixed time interval, otherwise consider as DFP has won & serving its own ad
        if !isAppEventExpected {
            _delegate?.adServerDidWin(bannerView)
            notified = true
        } else {
            // Timer to synchronize did recieve and app event callback as their sequence is not fixed
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: SYNC_TIMEOUT_INTEREVAL, target: self, selector: #selector(self.syncTimetAction), userInfo: nil, repeats: false)
        }
    }
    
    @objc func syncTimetAction() {
        if !notified {
            _delegate?.adServerDidWin(bannerView)
            notified = true
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        var eventErr:NSError?
        switch error.code {
        case GADErrorCode.noFill.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorNoAds)
            
        case GADErrorCode.invalidRequest.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorInvalidRequest)
            
        case GADErrorCode.networkError.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorNetworkError)
            
        case GADErrorCode.timeout.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorTimeout)
            
        case GADErrorCode.internalError.rawValue:
            fallthrough
        case GADErrorCode.interstitialAlreadyUsed.rawValue:
            fallthrough
        case GADErrorCode.mediationDataError.rawValue:
            fallthrough
        case GADErrorCode.mediationNoFill.rawValue:
            fallthrough
        case GADErrorCode.mediationAdapterError.rawValue:
            fallthrough
        case GADErrorCode.invalidArgument.rawValue:
            fallthrough
        case GADErrorCode.mediationInvalidAdSize.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorInternalError)
            
        case GADErrorCode.receivedInvalidResponse.rawValue:
            eventErr = eventError(error, code: POBErrorCode.errorInvalidResponse)

        default:
            eventErr = error
            break
        }
        _delegate?.failedWithError(eventErr)
    }
    
    func eventError(_ error : GADRequestError, code : POBErrorCode) -> NSError {
        let eventError = NSError(domain: kPOBErrorDomain, code:code.rawValue, userInfo: error.userInfo)
        return eventError
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        _delegate?.willPresentModal()
    }

    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        _delegate?.didDismissModal()
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        _delegate?.willLeaveApp()
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        dfpAdSize = size.size
    }


}
