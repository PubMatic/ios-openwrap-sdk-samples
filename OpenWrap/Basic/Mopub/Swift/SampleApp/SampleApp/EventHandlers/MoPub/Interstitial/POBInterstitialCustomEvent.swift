// This class is compatible with OpenWrap SDK v1.5.0 and MoPub SDK 5.10.0

import UIKit

class POBInterstitialCustomEvent: MPInterstitialCustomEvent, POBInterstitialRendererDelegate {
    
    var currentRenderer: POBInterstitialRendering?
    weak var viewController: UIViewController?
    
    // Method required for MoPub SDK versions 5.9.0 and below
    override func requestInterstitial(withCustomEventInfo info: [AnyHashable : Any]!) {
        self.loadAd(withCustomEventInfo: info)
    }
    
    // Method required for MoPub SDK versions 5.10.0 and above
    override func requestInterstitial(withCustomEventInfo info: [AnyHashable : Any]!, adMarkup: String!) {
        self.loadAd(withCustomEventInfo: info)
    }
    
    override func showInterstitial(fromRootViewController rootViewController: UIViewController!) {
        if rootViewController != nil {
            viewController = rootViewController
            let customData : [String:Any] = localExtras?["customData"] as! [String : Any]
            let loadTimeOrientation : NSNumber = customData["loadTimeOrientation"] as! NSNumber
            currentRenderer?.show(from: viewController!, in: UIInterfaceOrientation(rawValue:loadTimeOrientation.intValue)!)
        }
    }

    // MARK: - Supporting Methods
    
    func loadAd(withCustomEventInfo info: [AnyHashable : Any]!) {
        if localExtras == nil {
            self.handleCustomEventFailure()
            return
        }
        if let bid = localExtras["pob_bid"] as? POBBid {
            bid.hasWon = true
            currentRenderer = POBRenderer.interstitialRenderer()
            currentRenderer?.setDelegate(self)
            currentRenderer?.renderAdDescriptor(bid)
        }else{
            self.handleCustomEventFailure()
        }
    }

    func handleCustomEventFailure() -> Void {
        self.delegate.interstitialCustomEvent(self, didFailToLoadAdWithError: NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorInternalError.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Bid not available for custom event", comment: "Bid not available for custom event")]))
    }

// MARK: - POBInterstitialRendererDelegate

    func interstitialRendererDidRenderAd() {
        delegate.interstitialCustomEvent(self, didLoadAd: UIView())
    }
    
    func interstitialRendererDidFailToRenderAdWithError(_ error: Error!) {
        delegate.interstitialCustomEvent(self, didFailToLoadAdWithError: error)
    }
    
    func interstitialRendererDidClick() {
        delegate.interstitialCustomEventDidReceiveTap(self)
    }
    
    func interstitialRendererWillLeaveApp() {
        delegate.interstitialCustomEventWillLeaveApplication(self)
    }
    
    func interstitialRendererWillPresentModal() {
        delegate.interstitialCustomEventWillAppear(self)
        delegate.interstitialCustomEventDidAppear(self)
    }
    
    func interstitialRendererDidDismissModal() {
        delegate.interstitialCustomEventWillDisappear(self)
        delegate.interstitialCustomEventDidDisappear(self)
    }
    
    func interstitialRendererDidExpireAd() {
        delegate.interstitialCustomEventDidExpire(self)
    }
    
    func viewControllerForPresentingModal() -> UIViewController! {
        return viewController!
    }
    
    deinit {
        currentRenderer = nil
    }
}
