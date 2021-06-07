

import UIKit
import OpenWrapSDK

class BannerViewController: UIViewController,POBBannerViewDelegate,POBBidEventDelegate {

    let owAdUnit = "OpenWrapBannerAdUnit"
    let pubId = "156276"
    let profileId: NSNumber = 1165
    let isOWAuctionWin = true
    
    var bannerView: POBBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a banner view
        // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
        self.bannerView = POBBannerView(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit, adSizes: [POBAdSizeMake(320, 50)])
        
        // Set the delegate
        self.bannerView?.delegate = self
        
        // Set the bid event delegate
        self.bannerView?.bidEventDelegate = self

        // Add the banner view to your view hierarchy
        addBannerToView(banner: self.bannerView!, adSize: CGSize(width: 320, height: 50))
        
        // Load Ad
        self.bannerView?.loadAd()
    }
    
    // function simulates auction
    func auctionAndProceedWithBid(bid:POBBid) {
        print("Banner : Proceeding with load ad.")
        // Check if bid is expired
        if !bid.isExpired() {
            // Use bid, e.g. perform auction with your in-house mediation setup
            // ..
            // Auction complete
            if isOWAuctionWin {
                // OW bid won in the auction
                // Call bannerView?.proceedToLoadAd() to complete the bid flow
                bannerView?.proceedToLoadAd()
            }else{
                // Notify banner to proceed with auction loss error.
                bannerView?.proceed(onError: POBBidEventErrorCode.clientSideAuctionLoss, andDescription: "Client Side Auction Loss")
            }
        }else{
            // Notify banner view to proceed with the error.
            bannerView?.proceed(onError: POBBidEventErrorCode.adExpiry, andDescription: "bid expired")
        }
    }
    
    // MARK: - Bid event delegate methods
    // Notifies the delegate that bid has been successfully received.
    func bidEvent(_ bidEventObject: POBBidEvent!, didReceive bid: POBBid!) {
        // Make use of the received bid.
        print("Banner : Bid received.")
        // Notify banner view to proceed to load the ad after using the bid, e.g perform an auction
        auctionAndProceedWithBid(bid: bid)
    }
    
    // Notifies the delegate of an error encountered while fetching the bid.
    func bidEvent(_ bidEventObject: POBBidEvent!, didFailToReceiveBidWithError error: Error!) {
        // Notify banner view to proceed with the error.
        print("Banner : Bid receive failed with error : \(error.localizedDescription)")
        bannerView?.proceed(onError: POBBidEventErrorCode.other, andDescription: error.localizedDescription)
    }
    
    // MARK: - Banner view delegate methods
    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return self
    }
    
    // Notifies the delegate that an ad has been successfully loaded and rendered.
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        print("Banner : Ad received with size \(String(describing: bannerView.creativeSize())) ")
    }
    
    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView,
                    didFailToReceiveAdWithError error: Error) {
        print("Banner : Ad failed with error : \(error.localizedDescription )")
    }
    
    func addBannerToView(banner : POBBannerView?, adSize : CGSize) -> Void {
        
        banner?.frame = CGRect(x: (self.view.bounds.size.width - adSize.width)/2
            , y: self.view.bounds.size.height - adSize.height, width: adSize.width, height: adSize.height)
        
        banner?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner!)
        
        banner?.heightAnchor.constraint(equalToConstant: adSize.height).isActive = true
        banner?.widthAnchor.constraint(equalToConstant: adSize.width).isActive = true
        
        // Adding safe area constraints
        if #available(iOS 11.0, *) {
            let layoutGuide = view.safeAreaLayoutGuide
            banner?.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
            banner?.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true
        } else {
            let layoutMargineGuide = view.layoutMarginsGuide
            banner?.bottomAnchor.constraint(equalTo: layoutMargineGuide.bottomAnchor).isActive = true
            banner?.centerXAnchor.constraint(equalTo: layoutMargineGuide.centerXAnchor).isActive = true
        }
    }

    deinit {
        bannerView = nil
    }
}
