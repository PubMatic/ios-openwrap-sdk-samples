
#import "AppDelegate.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <OpenWrapSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [OpenWrapSDK setLogLevel:POBSDKLogLevelAll];

    // set test device for FB
   NSString *testDeviceKey = [FBAdSettings testDeviceHash];
   if (testDeviceKey) {
     [FBAdSettings setLogLevel:FBAdLogLevelLog];
     [FBAdSettings addTestDevice:testDeviceKey];
   }
    
    // Set a valid App Store URL, containing the app id of your iOS app.
    POBApplicationInfo *appInfo = [[POBApplicationInfo alloc] init];
    appInfo.storeURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8"];
    // This application information is a global configuration & you
    // need not set this for every ad request(of any ad type)
    [OpenWrapSDK setApplicationInfo:appInfo];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)) scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
