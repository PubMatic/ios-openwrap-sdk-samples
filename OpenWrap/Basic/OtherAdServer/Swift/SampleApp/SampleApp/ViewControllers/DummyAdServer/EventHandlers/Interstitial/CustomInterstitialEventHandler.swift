

import UIKit

/*!
 This class is responsible for communication between OpenWrap interstitial and interstitial ad from your ad server SDK(in this case DummyAdServerSDK).
 It implements the POBInterstitialEvent protocol. it notifies event back to OpenWrap SDK using POBInterstitialEventDelegate methods
 */
class CustomInterstitialEventHandler: NSObject,POBInterstitialEvent, DummyAdServerDelegate {

    weak var _delegate: POBInterstitialEventDelegate?
    var adServerSDK : DummyAdServerSDK?

    init(_ adUnit: String){
        super.init()
        adServerSDK = DummyAdServerSDK(adUnit: adUnit)
        adServerSDK?.delegate = self
    }
    
    // MARK: - POBInterstitialEvent
    func setDelegate(_ delegate: POBInterstitialEventDelegate) {
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
        adServerSDK?.loadInterstitailAd()
    }
    
    // Called when interstitial is about to show
    func show(from controller: UIViewController) {
        // Show ad using ad server SDK
        adServerSDK?.showInterstitial(from: controller)
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
    
    // Called when the interstitial ad is received.
    func didReceiveInterstitialAd() {
        _delegate?.adServerDidWin()
    }
    
    // Tells the delegate that an ad request failed. The failure is normally due to
    // network connectivity or ad availability (i.e., no fill).
    func didFailWithError(_ error: Error) {
        _delegate?.failedWithError(error)
    }
    //Similarly you can implement all the other ad flow events
}
