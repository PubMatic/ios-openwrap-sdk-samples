//This class is compatible with OpenWrap SDK v1.5.0

import UIKit

/*!
 This class is responsible for communication between OpenWrap banner view and Mopub banner view.
 It implements the POBBannerEvent protocol. it notifies event back to OpenWrap SDK using POBBannerEventDelegate methods
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
        // Create a MoPub Banner
        bannerView = MPAdView(adUnitId: adUnitId)
        bannerView?.maxAdSize = size
        adSize = bannerView?.adContentViewSize()
        
        // Set banner view frame
        var frame = bannerView?.frame
        frame?.size = size
        bannerView?.frame = frame ?? CGRect.zero
        
        // Set delegates on MPAdView instance, these should not be removed/overridden else event handler will not work as expected.
        bannerView?.delegate = self
        
        // Disable MPAdView refresh, refresh will be managed by OpenWrap SDK.
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
        // NOTE: Please do not remove this code. Need to reset MoPub banner delegate to MoPubBannerEventHandler as these are used by MoPubBannerEventHandler internally. Changing the mopub delegate to other instance may break the callbacks and the banner refresh mechanism.
        if !(bannerView?.delegate is MoPubBannerEventHandler) {
            NSLog("Resetting MoPub banner delegate to MoPubBannerEventHandler as these are used by MoPubBannerEventHandler internally.");
            bannerView?.delegate = self
        }
        bannerView?.loadAd()
    }
    
    func setDelegate(_ delegate: POBBannerEventDelegate) {
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
    
    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        contentSize = adSize
        let bid = self.bannerView?.localExtras["pob_bid"] as? POBBid
        if bid!.hasWon {
            _delegate?.openWrapPartnerDidWin()
        }
        else {
            _delegate?.adServerDidWin(view)
        }
    }
    
    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
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
    
    func willPresentModalView(forAd view: MPAdView!) {
        _delegate?.willPresentModal()
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        _delegate?.didDismissModal()
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        _delegate?.willLeaveApp()
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
