// This class is compatible with OpenWrap SDK v1.5.0 and MoPub SDK 5.10.0

import UIKit

class POBBannerCustomEvent: MPBannerCustomEvent {
    
    // Method required for MoPub SDK versions 5.9.0 and below
    override func requestAd(with size: CGSize, customEventInfo info: [AnyHashable : Any]!) {
        self.loadAd(with: size, customEventInfo: info)
    }
    
    // Method required for MoPub SDK versions 5.10.0 and above
    override func requestAd(with size: CGSize, customEventInfo info: [AnyHashable : Any]!, adMarkup: String!) {
        self.loadAd(with: size, customEventInfo: info)
    }
    
    // MARK: - Supporting Methods
    
    func loadAd(with size: CGSize, customEventInfo info: [AnyHashable : Any]!) {
        if localExtras == nil {
            self.handleCustomEventFailure()
            return
        }
        if let bid = localExtras["pob_bid"] as? POBBid {
            bid.hasWon = true
            //Removing POBBannerRenderer from this class, so removed the below method call from rendererDidRenderAd and added here to handle the refresh functionality for MoPub IBVideo.
            self.delegate.bannerCustomEvent(self, didLoadAd: UIView())
        }else{
            self.handleCustomEventFailure()
        }
    }
    
    func handleCustomEventFailure() -> Void {
        self.delegate.bannerCustomEvent(self, didFailToLoadAdWithError: NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorInternalError.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Bid not available for custom event", comment: "Bid not available for custom event")]))
    }
}
