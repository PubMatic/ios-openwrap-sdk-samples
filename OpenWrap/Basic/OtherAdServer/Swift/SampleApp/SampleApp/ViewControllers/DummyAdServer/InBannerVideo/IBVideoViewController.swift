

import UIKit

class IBVideoViewController: UIViewController,POBBannerViewDelegate {

    let owAdUnit  = "OtherASBannerAdUnit"
    let dummyAdServerAdUnit  = "OtherASBannerAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1757

    var bannerView: POBBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a banner custom event handler for your ad server. Make sure you use
        // separate event handler objects to create each banner view.
        // For example, The code below creates an event handler for DummyAdServer.
        let size300x250 = CGSize.init(width: 300, height: 250)
        let sizes =  [NSValue.init(cgSize: size300x250)]
    
        let eventHandler = CustomBannerEventHandler(dummyAdServerAdUnit, sizes: sizes)
        // Create a banner view
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
        self.bannerView = POBBannerView(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, eventHandler: eventHandler)
        // Set the delegate
        self.bannerView?.delegate = self

        // Add the banner view to your view hierarchy
        addBannerToView(banner: self.bannerView!, adSize: CGSize(width: 300, height: 250))
                
        // Load Ad
        self.bannerView?.loadAd()
    }
    
    func addBannerToView(banner : POBBannerView?, adSize : CGSize) -> Void {
        
        banner?.frame = CGRect(x: (self.view.bounds.size.width - adSize.width)/2
            , y: self.view.bounds.size.height - adSize.height, width: adSize.width, height: adSize.height)
        banner?.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(banner!)
    }
    
    // MARK: - Banner view delegate methods
    //Provides a view controller to use for presenting modal views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Banner : Ad received with size \(String(describing: bannerView.creativeSize())) ")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                           didFailToReceiveAdWithError error: Error?) {
        print("Banner : Ad failed with error : \(error?.localizedDescription ?? "")")
    }
    
    // Notifies the delegate whenever current app goes in the background due to user click
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        print("Banner : Will leave app")
    }
    
    // Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        print("Banner : Will present modal")
    }
    // Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        print("Banner : Dismissed modal")
    }

    deinit {
        bannerView = nil
    }
}
