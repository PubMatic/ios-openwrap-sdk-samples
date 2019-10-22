
import UIKit

class POBBannerCustomEvent: MPBannerCustomEvent, POBAdRendererDelegate {
    
    var bannerRenderer: POBBannerRendering?
    
    override func requestAd(with size: CGSize, customEventInfo info: [AnyHashable : Any]!) {
        if localExtras == nil {
            self.handleCustomEventFailure()
            return
        }
        if let bid = localExtras["pob_bid"] as? POBBid {
            bannerRenderer = POBRenderer.bannerRenderer()
            bannerRenderer?.setDelegate(self)
            bannerRenderer?.renderAdDescriptor(bid)
        }else{
            self.handleCustomEventFailure()
        }
    }
    
    func handleCustomEventFailure() -> Void {
        self.delegate.bannerCustomEvent(self, didFailToLoadAdWithError: NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorInternalError.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Bid not available for custom event", comment: "Bid not available for custom event")]))
    }
    
    // MARK: - POBAdRendererDelegate
    func rendererDidRenderAd(_ renderedAd: Any!, for ad: POBAdDescriptor!) {
        if let bid = localExtras["pob_bid"] as? POBBid {
            let rendererView = renderedAd as! UIView
            rendererView.frame = CGRect(x: 0, y: 0, width: (bid.size.width), height: (bid.size.height))
            self.delegate.bannerCustomEvent(self, didLoadAd: rendererView)
        }
    }
    
    func rendererDidFailToRenderAdWithError(_ error: Error!, for ad: POBAdDescriptor!) {
        self.delegate.bannerCustomEvent(self, didFailToLoadAdWithError: error)
    }
    
    func rendererWillLeaveApp() {
        self.delegate.bannerCustomEventWillLeaveApplication(self)
    }
    
    func rendererWillPresentModal() {
        self.delegate.bannerCustomEventWillBeginAction(self)
    }
    
    func rendererDidDismissModal() {
        self.delegate.bannerCustomEventDidFinishAction(self)
    }
    
    func viewControllerForPresentingModal() -> UIViewController! {
        return self.delegate.viewControllerForPresentingModalView()
    }
    
    deinit {
        bannerRenderer = nil
    }
}
