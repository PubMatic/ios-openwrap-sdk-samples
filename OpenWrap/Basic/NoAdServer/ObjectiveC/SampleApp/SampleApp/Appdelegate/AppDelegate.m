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

#import "AppDelegate.h"
@import OpenWrapSDK;

#define PUBLISHER_ID    @"156276"
#define PROFILE_ID      @1165

@interface AppDelegate ()
@property (strong) CLLocationManager* locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupNavigationBarAppearance];
    
    // Set log level before initializing OpenWrapSDK for debugging purpose.
    [OpenWrapSDK setLogLevel:POBSDKLogLevelAll];
    [OpenWrapSDK setSSLEnabled:NO];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    
    // Initialize OpenWrap SDK with publisher id and profile id.
    OpenWrapSDKConfig *openWrapSDKConfig = [[OpenWrapSDKConfig alloc] initWithPublisherId:PUBLISHER_ID
                                                                            andProfileIds:@[PROFILE_ID]];
    [OpenWrapSDK initializeWithConfig:openWrapSDKConfig
                 andCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"OpenWrap SDK initialization successful");
        } else {
            NSLog(@"OpenWrap SDK initialization failed with error : %@", error.localizedDescription);
        }

        // Set a valid App Store URL, containing the app id of your iOS app.
        POBApplicationInfo *appInfo = [[POBApplicationInfo alloc] init];
        appInfo.storeURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8"];

        // This application information is a global configuration & you
        // need not set this for every ad request(of any ad type)
        [OpenWrapSDK setApplicationInfo:appInfo];
        [OpenWrapSDK setDSAComplianceStatus:POBDSAComplianceStatusRequired];
    }];
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

#pragma mark - Private method

- (void)setupNavigationBarAppearance {
    // Define PubMatic brand color using RGB value.
    UIColor *navBarColor = [UIColor colorWithRed:51/255.0 green:151/255.0 blue:215/255.0 alpha:1.0];
    // Set the bar tint color (background color) for the navigation bar
    [[UINavigationBar appearance] setBarTintColor:navBarColor];

    // Set the tint color (color of navigation bar items) to white
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    // Define the title text attributes: white color and system font of size 16
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:16.0]
    };

    // Apply the title text attributes to the navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];

    // Ensure the navigation bar is not translucent
    [[UINavigationBar appearance] setTranslucent:NO];

    // Configure appearance for large titles (iOS 13+)
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        // Configure the appearance object to have an opaque background
        [appearance configureWithOpaqueBackground];

        // Set the background color of the navigation bar
        appearance.backgroundColor = navBarColor;

        // Set the text attributes for the standard-sized title
        appearance.titleTextAttributes = attributes;

        // Set the text attributes for the large-sized title
        appearance.largeTitleTextAttributes = attributes;

        // Apply the configured appearance to the standard appearance of the navigation bar
        [[UINavigationBar appearance] setStandardAppearance:appearance];

        // Apply the same appearance to the navigation bar when it's at the scroll edge
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
    }
}

@end
