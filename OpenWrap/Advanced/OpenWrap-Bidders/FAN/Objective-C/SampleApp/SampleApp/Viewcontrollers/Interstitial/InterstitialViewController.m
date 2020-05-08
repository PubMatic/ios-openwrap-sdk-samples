

#define OW_ADUNIT_ID    @"OpenWrapInterstitialAdUnit"
#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

#define FB_PLACEMENT_ID    @"2526468451010379_2526477531009471"
#define FB_APP_ID          @"2526468451010379"

#import "InterstitialViewController.h"
#import <POBInterstitial.h>
#import <POBFANBidder.h>

@interface InterstitialViewController ()<POBInterstitialDelegate>
@property (nonatomic) POBInterstitial *interstitial;
@property (nonatomic) IBOutlet UIButton *showAdButton;
@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an interstitial object
    // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
    self.interstitial = [[POBInterstitial alloc]
                                 initWithPublisherId:PUB_ID
                                 profileId:PROFILE_ID
                                 adUnitId:OW_ADUNIT_ID];
    // Set the delegate
    self.interstitial.delegate = self;
    
    NSMutableDictionary *custParams = [[NSMutableDictionary alloc] init];
    custParams[POBBidderKey_FB_App_Id] = FB_APP_ID;
    custParams[POBBidderKey_FB_PlacementId] = FB_PLACEMENT_ID;
    
    // Add bidder
    [self.interstitial addBidderSlotInfo:custParams forBidder:POBBidderIdFAN];
    
    self.interstitial.request.testModeEnabled = YES;
}

- (IBAction)loadAdAction:(id)sender {
    // Load Ad
    [self.interstitial loadAd];
}

- (IBAction)showAdAction:(id)sender {
    [self showInterstitialAd];
}

// To show interstitial ad call this method
- (void)showInterstitialAd{
    // ...
    if (self.interstitial.isReady) {
        // Show interstitial ad
        [self.interstitial showFromViewController:self];
    }
}

#pragma mark - Interstitial delegate methods

// Notifies the delegate that an ad has been received successfully.
- (void)interstitialDidReceiveAd:(nonnull POBInterstitial *)interstitial {
    self.showAdButton.hidden = NO;
    NSLog(@"Interstitial : Ad Received");
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)interstitial:(nonnull POBInterstitial *)interstitial didFailToReceiveAdWithError:(NSError * _Nullable)error {
    NSLog(@"Interstitial : Ad failed with error : %@", error.localizedDescription);
}

// Notifies the delegate that the interstitial ad will be presented as a modal on top of the current view controller.
- (void)interstitialWillPresentAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Will present");
}

// Notifies the delegate that the interstitial ad has been animated off the screen.
- (void)interstitialDidDismissAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Dismissed");
}

// Notifies the delegate of ad click
- (void)interstitialDidClickAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Ad Clicked");
}

// Notifies the delegate that a user interaction will open another app (e.g. App Store), leaving the current app.
- (void)interstitialWillLeaveApplication:(nonnull POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Will leave app");
}

#pragma mark - dealloc
- (void)dealloc {
    self.interstitial = nil;
}
@end


