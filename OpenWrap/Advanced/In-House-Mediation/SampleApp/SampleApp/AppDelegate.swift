/*
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 * Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 * Confidentiality and Non-disclosure agreements explicitly covering such access or to such other persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and nondisclosure obligations with respect to the source code.
 *
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 */

import UIKit
import OpenWrapSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private static let pubId = "156276"
    private static let profileId: NSNumber = 1165

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupNavigationBarAppearance()

        // Set log level before initializing OpenWrapSDK for debugging purpose.
        OpenWrapSDK.setLogLevel(.all)
        OpenWrapSDK.setSSLEnabled(false)

        let openWrapSDKConfig = OpenWrapSDKConfig(publisherId: Self.pubId, andProfileIds: [Self.profileId])
        OpenWrapSDK.initialize(with: openWrapSDKConfig) { (success, error) in
            if success {
                print("OpenWrap SDK initialization successful")
            } else if let error = error {
                print("OpenWrap SDK initialization failed with error : \(error.localizedDescription)")
            }

            // Set a valid App Store URL, containing the app id of your iOS app.
            let appInfo = POBApplicationInfo()
            appInfo.storeURL = URL(string: "https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8")!
            // This application information is a global configuration & you
            // need not set this for every ad request(of any ad type)
            OpenWrapSDK.setApplicationInfo(appInfo)
            OpenWrapSDK.setDSAComplianceStatus(.required)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: Private function

    func setupNavigationBarAppearance() {
        // Define PubMatic brand color using RGB value.
        let navBarColor = UIColor(red: 51/255.0, green: 151/255.0, blue: 215/255.0, alpha: 1.0)

        // Set the bar tint color (background color) for the navigation bar
        UINavigationBar.appearance().barTintColor = navBarColor

        // Set the tint color (color of navigation bar items) to white
        UINavigationBar.appearance().tintColor = .white

        // Define the title text attributes: white color and system font of size 16
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16.0)
        ]

        // Apply the title text attributes to the navigation bar
        UINavigationBar.appearance().titleTextAttributes = attributes

        // Ensure the navigation bar is not translucent
        UINavigationBar.appearance().isTranslucent = false

        // Configure appearance for large titles (iOS 13+)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            // Configure the appearance object to have an opaque background
            appearance.configureWithOpaqueBackground()

            // Set the background color of the navigation bar
            appearance.backgroundColor = navBarColor

            // Set the text attributes for the standard-sized title
            appearance.titleTextAttributes = attributes

            // Set the text attributes for the large-sized title
            appearance.largeTitleTextAttributes = attributes

            // Apply the configured appearance to the standard appearance of the navigation bar
            UINavigationBar.appearance().standardAppearance = appearance

            // Apply the same appearance to the navigation bar when it's at the scroll edge
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

