

import UIKit
import OpenWrapSDK

/*!
 This class is responsible for communication between OpenWrap banner view and banner view from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBBannerEvent protocol. it notifies event back to OpenWrap SDK using POBBannerEventDelegate methods
 */
class CustomBannerEventHandler: NSObject,POBBannerEvent, DummyAdServerDelegate {

    weak var _delegate: POBBannerEventDelegate?
    var adServerSDK : DummyAdServerSDK?
    var adSizes : Array<NSValue>?
    
    init(_ adUnit: String, sizes: Array<NSValue>){
        super.init()
        adSizes = sizes
        adServerSDK = DummyAdServerSDK(adUnit: adUnit)
        adServerSDK?.delegate = self
    }
    
    // MARK: - POBBannerEvent
    
    func setDelegate(_ delegate: POBBannerEventDelegate) {
        _delegate = delegate
    }

    // OpenWrap SDK passes its bids through this method. You should request an ad from your ad server here.
    func requestAd(with bid: POBBid?) {
        // If bid is valid, add bid related custom targeting on the ad request
        if bid != nil {
            adServerSDK?.setCustomTargeting((bid?.targetingInfo())!)
            print("Custom targeting : \(String(describing: bid?.targetingInfo()?.description))")
        }
        // Load ad from the ad server
        adServerSDK?.loadBannerAd()
    }
    
    //return the content size of the ad received from the ad server
    func adContentSize() -> CGSize {
        return CGSize(width: 320, height: 50)
    }
    
    // return requested ad sizes for the bid request
    func requestedAdSizes() -> [POBAdSize] {
        var sizes:[POBAdSize] = []
        for value in adSizes! {
            sizes.append(POBAdSize(cgSize: value.cgSizeValue))
        }
        return sizes
    }
        
    // MARK: - DummyAdServerDelegate
    
    // A dummy custom event triggered based on targeting information sent in the request.
    // This sample uses this event to determine if the partner ad should be served.
    func didReceiveCustomEvent(_ event: String) {
        // Identify if the ad from OpenWrap partner is to be served and, if so, call 'openWrapPartnerDidWin'
        if event == "SomeCustomEvent" {
            // partner ad should be served
            _delegate?.openWrapPartnerDidWin()
        }
    }

    // Called when the banner ad is loaded from ad server.
    func didLoadBannerAd(_ bannerView: UIView) {
        _delegate?.adServerDidWin(bannerView)
    }
    
    // Tells the delegate that an ad request failed. The failure is normally due to
    // network connectivity or ad availability (i.e., no fill).
    func didFailWithError(_ error: Error) {
        _delegate?.failedWithError(error)
    }
    //Similarly you can implement all the other ad flow events
}
