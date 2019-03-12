/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2019 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of
 * PubMatic. The intellectual and technical concepts contained herein are
 * proprietary to PubMatic and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from PubMatic.
 * Access to the source code contained herein is hereby forbidden to anyone
 * except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such
 * access.
 *
 * The copyright notice above does not evidence any actual or intended
 * publication or disclosure  of  this source code, which includes information
 * that is confidential and/or proprietary, and is a trade secret, of  PubMatic.
 * ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC
 * DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN
 * CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE
 * CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS TO
 * REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR
 * SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

import UIKit

class POBInterstitialCustomEvent: MPInterstitialCustomEvent, POBInterstitialRendererDelegate {
    
    var currentRenderer: POBInterstitialRendering?
    weak var viewController: UIViewController?
    
    override func requestInterstitial(withCustomEventInfo info: [AnyHashable : Any]!) {
        
        if let bid = localExtras["pob_bid"] as? POBBid {
            currentRenderer = POBRenderer.interstitialRenderer()
            currentRenderer?.setDelegate(self)
            currentRenderer?.renderAdDescriptor(bid)
        }else{
            self.delegate.interstitialCustomEvent(self, didFailToLoadAdWithError: NSError(domain: kPOBErrorDomain, code: POBErrorCode.errorInternalError.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Bid not available for custom event", comment: "Bid not available for custom event")]))
        }
    }
    
    override func showInterstitial(fromRootViewController rootViewController: UIViewController!) {
        if rootViewController != nil {
            viewController = rootViewController
            let customData : [String:Any] = localExtras?["customData"] as! [String : Any]
            let loadTimeOrientation : NSNumber = customData["loadTimeOrientation"] as! NSNumber
            currentRenderer?.show(from: viewController!, in: UIInterfaceOrientation(rawValue:loadTimeOrientation.intValue)!)
        }
    }

// MARK: - PMInterstitialRendererDelegate

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
    
    func viewControllerForPresentingModal() -> UIViewController! {
        return viewController!
    }
}
