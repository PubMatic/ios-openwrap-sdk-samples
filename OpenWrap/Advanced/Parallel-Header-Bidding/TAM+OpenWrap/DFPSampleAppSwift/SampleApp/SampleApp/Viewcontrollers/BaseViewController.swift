/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical
 * concepts contained herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in
 * process, and are protected by trade secret or copyright law. Dissemination of this information or reproduction of
 * this material is strictly forbidden unless prior written permission is obtained from PubMatic.  Access to the source
 * code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors
 * who have executed Confidentiality and Non-disclosure agreements explicitly covering such access or to such other
 * persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and
 * nondisclosure obligations with respect to the source code.
 *
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code,
 * which includes information that is confidential and/or proprietary, and is a trade secret, of  PubMatic. ANY
 * REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE
 * CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE LAWS
 * AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT
 * CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL
 * ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

import OpenWrapSDK
import UIKit

// MARK: - BaseViewController

class BaseViewController: UIViewController {
    // MARK: IBOutlet

    @IBOutlet private var logTextView: UITextView! {
        didSet {
            updateLogTextView()
        }
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        log("OpenWrap SDK Version : \(OpenWrapSDK.version()!)")
    }

    // MARK: Public APIs

    func log(_ message: String) {
        print(message)
        performOnMainThread { [weak self] in
            guard let self else { return }
            logTextView.text = logTextView.text + message + "\n"
        }
    }

    // MARK: View Appearance

    private func updateLogTextView() {
        logTextView.isEditable = false
        logTextView.text = ""
    }
}

// MARK: - Utils

/// Ensures that the operation is performed on the main thread.
func performOnMainThread(_ operation: @escaping () -> Void) {
    if Thread.isMainThread {
        operation()
    } else {
        DispatchQueue.main.async(execute: operation)
    }
}
