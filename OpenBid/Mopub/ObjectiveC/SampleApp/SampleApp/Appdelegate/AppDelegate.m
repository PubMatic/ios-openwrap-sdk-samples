

#import "AppDelegate.h"
#import <OpenBidSDK.h>
#import <MoPub.h>

@interface AppDelegate ()
@property (strong) CLLocationManager* locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:51/255.0 green:151/255.0 blue:215/255.0 alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:16.0],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [OpenBidSDK setLogLevel:POBSDKLogLevelAll];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [OpenBidSDK setSSLEnabled:NO];

    // Set a valid App Store URL, containing the app id of your iOS app.
    POBApplicationInfo *appInfo = [[POBApplicationInfo alloc] init];
    appInfo.storeURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8"];
    // This application information is a global configuration & you
    // need not set this for every ad request(of any ad type)
    [OpenBidSDK setApplicationInfo:appInfo];
    MPMoPubConfiguration *mopubConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"7dd627733dab46d19755fb2da299b8c7"];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:mopubConfig completion:nil];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
