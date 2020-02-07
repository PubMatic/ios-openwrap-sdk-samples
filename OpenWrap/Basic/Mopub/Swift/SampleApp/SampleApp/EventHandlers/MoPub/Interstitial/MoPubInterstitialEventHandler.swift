//This class is compatible with OpenWrap SDK v1.5.0

import UIKit

/*!
 This class is responsible for communication between OpenWrap interstitial and Mopub interstitial controller.
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenWrap SDK using POBInterstitialEventDelegate methods
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
    }

    deinit {
        if interstitial != nil {
            MPInterstitialAdController.removeSharedInterstitialAdController(interstitial)
            interstitial?.delegate = nil
            interstitial = nil
        }
        _delegate = nil
        configBlock = nil
    }

    // MARK: - POBInterstitialEvent
    func setDelegate(_ delegate: POBInterstitialEventDelegate) {
        _delegate = delegate
    }
    
    func requestAd(with bid: POBBid?) {
        
        interstitial = MPInterstitialAdController(forAdUnitId: adUnitId)

        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        interstitial?.delegate = self
        interstitial?.keywords = nil;

        // If bid is valid, add bid related keywords on Mopub view
        if bid != nil {
            if (configBlock != nil) {
                configBlock!(interstitial!)
            }

            let keywords = self.keywords(for: bid)
            interstitial?.keywords = keywords

            print("MoPub interstitial keywords: \(String(describing: keywords))")

            var localExtras = interstitial?.localExtras ?? [AnyHashable:Any]()
            localExtras["customData"] = _delegate?.customData()
            if bid?.status.boolValue ?? false {
                localExtras["pob_bid"] = bid
            }
            interstitial?.localExtras = localExtras
        }
        // NOTE: Please do not remove this code. Need to reset MoPub interstitial delegate to MoPubInterstitialEventHandler as these are used by MoPubInterstitialEventHandler internally. Changing the mopub delegate to other instance may break the callback mechanism.
        if !(interstitial?.delegate is MoPubInterstitialEventHandler) {
            NSLog("Resetting MoPub interstitial delegate to MoPubInterstitialEventHandler as these are used by MoPubInterstitialEventHandler internally.");
            interstitial?.delegate = self
        }
        interstitial?.loadAd()
    }

    
    func show(from controller: UIViewController) {
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
    
    func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
        _delegate?.adDidExpireAd()
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
