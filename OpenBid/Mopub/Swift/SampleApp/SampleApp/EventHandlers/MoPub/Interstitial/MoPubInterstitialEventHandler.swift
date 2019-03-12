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
 This class is responsible for communication between OpenBid interstitial and Mopub interstitial controller.
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenBid SDK using POBInterstitialEventDelegate methods
 */
class MoPubInterstitialEventHandler: NSObject, POBInterstitialEvent, MPInterstitialAdControllerDelegate {

    /*!
     Mopub interstitial configuration block having MPInterstitialAdController as parameter
     */
    typealias MPInterstitialConfigBlock = (MPInterstitialAdController) -> Void
    
    var interstitial: MPInterstitialAdController?
    weak var _delegate: POBInterstitialEventDelegate?
    var adUnitId = ""
    
    /*!
     A configBlock that is called before event handler makes ad request call to Mopub SDK. It passes MPInterstitialAdController which will be used to make ad request.
     */
    var configBlock: MPInterstitialConfigBlock?

    /*!
     Initializes and returns a event handler with the specified Mopub ad unit
     
     @param adUnitId Mopub ad unit id
     */
    init(_ adUnitId: String) {
        super.init()
        self.adUnitId = adUnitId
        self.interstitial = MPInterstitialAdController(forAdUnitId: self.adUnitId)
        
        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        self.interstitial?.delegate = self
    }

    deinit {
        interstitial?.delegate = nil
        interstitial = nil
        _delegate = nil
        configBlock = nil
    }

    // MARK: - POBInterstitialEvent
    func setDelegate(_ delegate: POBInterstitialEventDelegate?) {
        _delegate = delegate
    }
    
    func requestAd(with bid: POBBid?) {
        
        interstitial?.keywords = nil;

        if !(interstitial?.delegate is MoPubInterstitialEventHandler) {
            NSLog("Do not set Mopub delegate. These are used by MoPubInterstitialEventHandler internally.");
        }

        // If bid is valid, add bid related keywords on Mopub view
        if bid != nil {
            if (configBlock != nil) {
                configBlock!(interstitial!)
            }

            let keywords = self.keywords(for: bid)
            interstitial?.keywords = keywords

            print("MoPub interstitial keywords: \(String(describing: keywords))")

                if bid?.status.boolValue ?? false {
                    var localExtras = interstitial?.localExtras ?? [AnyHashable:Any]()
                    localExtras["pob_bid"] = bid
                    localExtras["customData"] = _delegate?.customData()
                    interstitial?.localExtras = localExtras
                }
        }
        interstitial?.loadAd()
    }

    
    func show(from controller: UIViewController?) {
        if interstitial?.ready ?? false {
            interstitial?.show(from: controller)
        } else {
            print("Interstitial ad is not ready to show.")
        }
    }

    // MARK: - MPInterstitialAdControllerDelegate
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        _delegate?.adServerDidWin()
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        let failureMsg = NSLocalizedString("MoPub ad server failed to load ad", comment: "")
        let userInfo = [NSLocalizedDescriptionKey: failureMsg,
                        NSLocalizedFailureReasonErrorKey: failureMsg]
        let eventError = NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorNoAds.rawValue, userInfo: userInfo)
        _delegate?.failedWithError(eventError)
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!, withError error: Error!) {
        var eventErr = error as NSError
        let mopubError = MOPUBErrorCode(rawValue: Int32(eventErr.code))
        
        switch mopubError {
        case MOPUBErrorNoNetworkData:
            fallthrough
        case MOPUBErrorNoInventory:
            fallthrough
        case MOPUBErrorAdapterHasNoInventory:
            // No data found in NSHTTPURL response
            eventErr = eventError(eventErr, code: POBErrorCode.errorNoAds)
            
        case MOPUBErrorNetworkTimedOut:
            eventErr = eventError(eventErr, code: POBErrorCode.errorNetworkError)
            
        case MOPUBErrorServerError:
            eventErr = eventError(eventErr, code: POBErrorCode.errorServerError)
            
        case MOPUBErrorAdRequestTimedOut:
            eventErr = eventError(eventErr, code: POBErrorCode.errorTimeout)
            
        case MOPUBErrorAdapterInvalid:
            fallthrough
        case MOPUBErrorAdapterNotFound:
            eventErr = eventError(eventErr, code: POBErrorCode.signalingError)
            
        case MOPUBErrorAdUnitWarmingUp:
            fallthrough
        case MOPUBErrorSDKNotInitialized:
            eventErr = eventError(eventErr, code: POBErrorCode.errorInternalError)
            
        case MOPUBErrorUnableToParseJSONAdResponse:
            fallthrough
        case MOPUBErrorUnexpectedNetworkResponse:
            eventErr = eventError(eventErr, code: POBErrorCode.errorInvalidResponse)
            
        case MOPUBErrorNoRenderer:
            eventErr = eventError(eventErr, code: POBErrorCode.errorRenderError)
        default:
            break
        }
        _delegate?.failedWithError(eventErr)
    }
    
    func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
        _delegate?.willPresentAd()
    }
    
    func interstitialDidDisappear(_ interstitial: MPInterstitialAdController!) {
        _delegate?.didDismissAd()
    }
    
    func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
        _delegate?.didClickAd()
    }
    
    // MARK: - Helper methods
    func eventError(_ error : NSError, code : POBErrorCode) -> NSError {
        let eventError = NSError(domain: kPOBErrorDomain, code:code.rawValue, userInfo: error.userInfo)
        return eventError
    }
    
    func keywords(for bid: POBBid?) -> String? {
        var keywords = ""
        let targetingInfo = bid?.targetingInfo()
        for key in (targetingInfo?.keys)! {
            keywords += String(format: "%@:%@,", key as! String,targetingInfo?[key] as! String)
        }
        
        if ((interstitial?.keywords?.count) != nil) {
            keywords += interstitial?.keywords ?? ""
        }else{
            if keywords.count != 0 {
                if let subRange = Range<String.Index>(NSRange(location: keywords.count - 1, length: 1), in: keywords) { keywords.removeSubrange(subRange) }
            }
        }
        return keywords
    }
}
