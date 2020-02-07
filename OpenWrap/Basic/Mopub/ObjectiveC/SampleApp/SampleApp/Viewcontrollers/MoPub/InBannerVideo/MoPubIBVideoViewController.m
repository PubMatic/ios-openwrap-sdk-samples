

#import "MoPubIBVideoViewController.h"
#import <POBBannerView.h>
#import "MoPubBannerEventHandler.h"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1758
#define MOPUB_AD_UNIT   @"c7ecf4d1567b45b188a56e731a1a77fe"
#define OW_AD_UNIT      @"c7ecf4d1567b45b188a56e731a1a77fe"

@interface MoPubIBVideoViewController ()<POBBannerViewDelegate>
@property (nonatomic) POBBannerView *bannerView;
@end

@implementation MoPubIBVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a banner custom event handler for your ad server. Make sure you use
    // separate event handler objects to create each banner view.
    // For example, The code below creates an event handler for MoPub ad server.
    CGSize size = CGSizeMake(300.0, kMPPresetMaxAdSize250Height.height);
    MoPubBannerEventHandler *eventHandler = [[MoPubBannerEventHandler alloc] initWithAdUnitId:MOPUB_AD_UNIT adSize:size];
    
    // Create a banner view
    // For test IDs refer - https://community.pubmatic.com/x/_xQ5AQ#TestandDebugYourIntegration-TestProfile/Placements
    self.bannerView = [[POBBannerView alloc]
                       initWithPublisherId:PUB_ID
                       profileId:PROFILE_ID
                       adUnitId:OW_AD_UNIT
                       eventHandler:eventHandler];
    
    // Set the delegate
    self.bannerView.delegate = self;

    // Add the banner view to your view hierarchy
    [self addBannerToView:self.bannerView withSize:size];
    
    // Load Ad
    [self.bannerView loadAd];
}

- (void)addBannerToView:(UIView *)bannerView withSize:(CGSize )size{
    bannerView.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-size.width)/2,
                                  CGRectGetHeight(self.view.bounds)-size.height,
                                  size.width, size.height);
    bannerView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                   UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleRightMargin);
    [self.view addSubview:bannerView];
}

#pragma mark - Banner view delegate methods
//Provides a view controller to use for presenting model views
- (UIViewController *)bannerViewPresentationController {
    return self;
}

// Notifies the delegate that an ad has been successfully loaded and rendered.
- (void)bannerViewDidReceiveAd:(POBBannerView *)bannerView {
    NSLog(@"Banner : Ad received with size %@ ", bannerView.creativeSize);
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)bannerView:(POBBannerView *)bannerView
didFailToReceiveAdWithError:(NSError *_Nullable)error {
    NSLog(@"Banner : Ad failed with error : %@", [error localizedDescription]);
}

// Notifies the delegate whenever current app goes in the background due to user click
- (void)bannerViewWillLeaveApplication:(POBBannerView *)bannerView {
    NSLog(@"Banner : Will leave app");
}

// Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
- (void)bannerViewWillPresentModal:(POBBannerView *)bannerView {
    NSLog(@"Banner : Will present modal");
}

// Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
- (void)bannerViewDidDismissModal:(POBBannerView *)bannerView {
    NSLog(@"Banner : Dismissed modal");
}

#pragma mark - dealloc
- (void)dealloc {
    _bannerView = nil;
}

@end
