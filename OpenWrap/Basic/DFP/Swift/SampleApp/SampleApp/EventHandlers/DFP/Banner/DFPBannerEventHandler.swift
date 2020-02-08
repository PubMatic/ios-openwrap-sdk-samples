//This class is compatible with OpenWrap SDK v1.5.0

import UIKit
import GoogleMobileAds

/*!
 This class is responsible for communication between OpenWrap banner view and DFP banner view.
 It implements the POBBannerEvent protocol. it notifies event back to OpenWrap SDK using POBBannerEventDelegate methods
 */
class DFPBannerEventHandler: NSObject,POBBannerEvent,GADBannerViewDelegate,GADAppEventDelegate,GADAdSizeDelegate {

    let SYNC_TIMEOUT_INTEREVAL = 0.6
        
    var bannerView: DFPBannerView?
    var timer: Timer?
    weak var _delegate: POBBannerEventDelegate?
    var dfpAdSize = CGSize.zero
    var notified = false
    var isAppEventExpected = false
    var adSizes = [NSValue]()
    
    /*!
     A configureBlock that is called before event handler makes ad request call to DFP SDK. It passes DFPBannerView & DFPRequest which will be used to make ad request.
     */
    var configBlock: ((_ view: DFPBannerView, _ request: DFPRequest)->Void)?


    /*!
     Initializes and returns a event handler with the specified DFP ad unit and ad sizes
     
     @param adUnitId DFP ad unit id
     @param validSizes Array of NSValue encoded GADAdSize structs. Never create your own GADAdSize directly. Use one of the predefined
     standard ad sizes (such as kGADAdSizeBanner), or create one using the GADAdSizeFromCGSize
     method.
     Example:
     <pre>
     NSArray *validSizes = @[
     NSValueFromGADAdSize(kGADAdSizeBanner),
     NSValueFromGADAdSize(kGADAdSizeLargeBanner)
     ];
     bannerView.validAdSizes = validSizes;
     </pre>
     
     */
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
    
    func setDelegate(_ delegate: POBBannerEventDelegate) {
        _delegate = delegate
    }

    func requestAd(with bid: POBBid?) {
        
        notified = false
        isAppEventExpected = false
        bannerView?.rootViewController = _delegate?.viewControllerForPresentingModal()
        let dfpRequest = DFPRequest()
        
        self.configBlock?(bannerView!,dfpRequest)
        
        if !(bannerView?.appEventDelegate is DFPBannerEventHandler
            && bannerView?.delegate is DFPBannerEventHandler) {
                NSLog("Do not set DFP delegates. These are used by DFPBannerEventHandler internally.");
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
            _delegate?.openWrapPartnerDidWin()
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
            _delegate?.adServerDidWin(bannerView!)
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