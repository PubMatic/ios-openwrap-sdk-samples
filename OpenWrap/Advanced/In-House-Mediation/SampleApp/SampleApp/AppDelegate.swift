
import UIKit
import OpenWrapSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        OpenWrapSDK.setLogLevel(.all)
        
        // Set a valid App Store URL, containing the app id of your iOS app.
        let appInfo = POBApplicationInfo()
        appInfo.storeURL = URL(string: "https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8")!
        // This application information is a global configuration & you
        // need not set this for every ad request(of any ad type)
        OpenWrapSDK.setApplicationInfo(appInfo)

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


}

