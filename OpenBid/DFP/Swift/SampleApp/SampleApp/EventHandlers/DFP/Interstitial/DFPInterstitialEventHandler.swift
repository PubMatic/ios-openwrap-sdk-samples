

import UIKit
import GoogleMobileAds

/*!
 This class is responsible for communication between OpenBid interstitial and DFP interstitial .
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenBid SDK using POBInterstitialEventDelegate methods
 */
class DFPInterstitialEventHandler: NSObject,POBInterstitialEvent,GADAppEventDelegate,GADInterstitialDelegate {

    let SYNC_TIMEOUT_INTEREVAL = 0.8
    
    var interstitial: DFPInterstitial?
    weak var _delegate: POBInterstitialEventDelegate?
    var adUnitId = ""
    var timer: Timer?
    var notified = false
    var isAppEventExpected = false
    
    /*!
     A configBlock that is called before event handler makes ad request call to DFP SDK. It passes DFPInterstitial & DFPRequest which will be used to make ad request.
     */
    var configBlock: ((_ view: DFPInterstitial, _ request: DFPRequest)->Void)?

    init(_ adUnitId: String) {
        super.init()
        self.adUnitId = adUnitId
    }
    
    deinit {
        interstitial?.delegate = nil
        interstitial = nil
    }
    
    func setDelegate(_ delegate: POBInterstitialEventDelegate?) {
        _delegate = delegate
    }

    func requestAd(with bid: POBBid?) {
        
        notified = false
        isAppEventExpected = false
        interstitial = DFPInterstitial(adUnitID: adUnitId)
        interstitial?.delegate = self
        interstitial?.appEventDelegate = self
        
        let dfpRequest = DFPRequest()
        
        self.configBlock?(interstitial!,dfpRequest)
        
        if !(interstitial?.appEventDelegate is DFPInterstitialEventHandler
            && interstitial?.delegate is DFPInterstitialEventHandler) {
            NSLog("Do not set DFP delegates. These are used by DFPInterstitialEventHandler internally.");
        }

        if bid != nil {
            if bid?.status.boolValue ?? false {
                isAppEventExpected = true
            }
            let customTargeting = NSMutableDictionary()
            customTargeting.addEntries(from: dfpRequest.customTargeting ?? [:])
            customTargeting.addEntries(from: bid?.targetingInfo() ?? [:]);
            dfpRequest.customTargeting = customTargeting as? [AnyHashable : Any]
            print("Custom targeting : \(String(describing: customTargeting.description))")
        }
        interstitial?.load(dfpRequest)
    }
    
    func show(from controller: UIViewController) {
        interstitial?.present(fromRootViewController: controller)
    }

    func interstitial(_ interstitial: GADInterstitial, didReceiveAppEvent name: String, withInfo info: String?) {
        
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
            self.interstitial?.delegate = nil
            self.interstitial = nil
            _delegate?.openBidPartnerDidWin()
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if notified {
            return
        }
        
        if !isAppEventExpected {
            if !notified {
                _delegate?.adServerDidWin()
                notified = true
            }
        } else {
            // Timer to synchronize did recieve and app event callback as their sequence is not fixed
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: SYNC_TIMEOUT_INTEREVAL, target: self, selector: #selector(self.syncTimetAction), userInfo: nil, repeats: false)
        }
    }
    
    @objc func syncTimetAction() {
        if !notified {
            _delegate?.adServerDidWin()
            notified = true
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
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
        case GADErrorCode.invalidArgument.rawValue:
            fallthrough
        case GADErrorCode.mediationAdapterError.rawValue:
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
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        _delegate?.willPresentAd()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        _delegate?.didDismissAd()
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        /*
         GADInterstitialDelegate doesn't provide didClickAd callback. Since user click
         has triggered the willLeaveApplication event, the interstitial event handler
         can safely give didClickAd callback.
         */
        _delegate?.didClickAd()
        _delegate?.willLeaveApp()
    }
}
