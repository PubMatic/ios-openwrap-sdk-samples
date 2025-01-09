/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic.
* The intellectual and technical concepts contained herein are proprietary to PubMatic
* and may be covered by U.S. and Foreign Patents, patents in process, and are protected
* by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly
* forbidden unless prior written permission is obtained from PubMatic.
* Access to the source code contained herein is hereby forbidden to anyone except current
* PubMatic employees, managers or contractors who have executed Confidentiality and
* Non-disclosure agreements explicitly covering such access or to such other persons whom
* are directly authorized by PubMatic to access the source code and are subject to
* confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or
* disclosure  of  this source code, which includes information that is confidential
* and/or proprietary, and is a trade secret, of  PubMatic.
* ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC DISPLAY
* OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF
* PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL
* TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION
* DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS
* CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE,
* IN WHOLE OR IN PART.
*/

import DTBiOSSDK
import UIKit

/// Bidder class to load bids from TAM SDK.

class TAMAdLoader: NSObject, DTBAdCallback, Bidding {

    /**
     @abstract Sets the BidderDelegate delegate receiver which will notify about response (success/failure) from TAM SDK to bidding manager
     */
    weak var delegate: BidderDelegate?
    var adSize: DTBAdSize?
    var adLoader: DTBAdLoader?

    init(size: DTBAdSize?) {
        super.init()
        adSize = size
    }

    // MARK: - Bidding protocol method

    func loadBids() {
        print("TAM: Loading ad from A9 TAM SDK")
        adLoader = DTBAdLoader()
        adLoader?.setAdSizes([adSize!])
        adLoader?.loadAd(self)
    }

    // MARK: - DTBAdCallback
    func onFailure(_ error: DTBAdError) {
        print("TAM: Failed to load ad with error :\(error)")
        let err = NSError(
            domain: "Failed to load ad from TAM SDK.", code: Int(error.rawValue), userInfo: nil)
        // Notify failure to bidding manager
        delegate?.bidder(self, didFailToReceiveAdWithError: err)
    }

    func onSuccess(_ adResponse: DTBAdResponse?) {
        print("TAM: Received Response From A9 TAM SDK")
        // Pass TAM custom targeting parameters to bidding manager.
        if let custom = adResponse?.customTargeting() {
            delegate?.bidder(
                self,
                didReceivedAdResponse: [
                    "TAM": custom
                ])
        }
    }

}
