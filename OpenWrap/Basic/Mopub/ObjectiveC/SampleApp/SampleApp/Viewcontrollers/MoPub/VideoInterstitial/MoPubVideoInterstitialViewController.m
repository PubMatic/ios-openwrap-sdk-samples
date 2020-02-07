
#define MOPUB_AD_UNIT   @"d77111b8b59b484c8c92cb2e73c204a6"
#define OW_AD_UNIT      @"d77111b8b59b484c8c92cb2e73c204a6"
#define PUB_ID          @"156276"
#define PROFILE_ID      @1758

#import "MoPubVideoInterstitialViewController.h"
#import "MoPubInterstitialEventHandler.h"
#import <POBInterstitial.h>

@interface MoPubVideoInterstitialViewController () <POBInterstitialDelegate>

@property (nonatomic) POBInterstitial *interstitial;
@property (nonatomic) IBOutlet UIButton *showAdButton;

@end


@implementation MoPubVideoInterstitialViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an interstitial custom event handler for your ad server. Make
    // sure you use separate event handler objects to create each interstitial
    // For example, The code below creates an event handler for MoPub ad server.
    MoPubInterstitialEventHandler *eventHandler = [[MoPubInterstitialEventHandler alloc] initWithAdUnitId:MOPUB_AD_UNIT];
    
    // Create an interstitial object
    // For test IDs refer - https://community.pubmatic.com/x/_xQ5AQ#TestandDebugYourIntegration-TestProfile/Placements
    self.interstitial = [[POBInterstitial alloc] initWithPublisherId:PUB_ID
                                                           profileId:PROFILE_ID
                                                            adUnitId:OW_AD_UNIT
                                                        eventHandler:eventHandler];
    // Set the delegate
    self.interstitial.delegate = self;
}


#pragma mark - Dealloc

- (void)dealloc {
    self.interstitial = nil;
}


#pragma mark - IBActions

- (IBAction)loadAdAction:(id)sender {
    // Load Ad
    [self.interstitial loadAd];
}

- (IBAction)showAdAction:(id)sender {
    [self showInterstitialAd];
}

// To show interstitial ad call this method
- (void)showInterstitialAd{
    // Ensure ad is ready to display
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

// Notifies the delegate of an ad expiration. After this callback, this 'POBInterstitial' instance is marked as invalid & will not be shown.
- (void)interstitialDidExpireAd:(POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Ad Expired");
}

@end



