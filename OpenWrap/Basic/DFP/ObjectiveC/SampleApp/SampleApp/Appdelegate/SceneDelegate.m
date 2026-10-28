/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2026 PubMatic, All Rights Reserved.
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

#import "SceneDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface SceneDelegate () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL hasRequestedPermissions;
@property (nonatomic, assign) BOOL hasScheduledTrackingPermission;
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // If using a storyboard, the window property is initialized and attached to the scene.
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Request location, then ATT, once the scene is active so the system dialogs can be presented.
    [self requestPermissionsIfNeeded];
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

#pragma mark - Permissions

- (void)requestPermissionsIfNeeded {
    if (self.hasRequestedPermissions) {
        return;
    }
    self.hasRequestedPermissions = YES;

    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }

    if (self.locationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        return;
    }

    // Location is already determined, so continue to ATT once the app view is available.
    [self scheduleTrackingPermissionRequest];
}

- (void)scheduleTrackingPermissionRequest {
    if (self.hasScheduledTrackingPermission) {
        return;
    }
    self.hasScheduledTrackingPermission = YES;

    // Add delay of 0.5 seconds to ensure the ATT dialogue is presented once the app view is available.
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf requestTrackingPermission];
    });
}

- (void)requestTrackingPermission {
    if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusNotDetermined) {
        return;
    }

    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        NSLog(@"ATT permission status: %ld", (long)status);
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    // The delegate is invoked when it is assigned, including while status is still not determined.
    // Wait until location is resolved so the ATT dialogue is not covered by the location prompt.
    if (!self.hasRequestedPermissions || manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    [self scheduleTrackingPermissionRequest];
}

@end
