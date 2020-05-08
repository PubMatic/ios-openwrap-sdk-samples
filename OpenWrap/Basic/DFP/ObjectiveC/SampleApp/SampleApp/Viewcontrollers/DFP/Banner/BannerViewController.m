

#import "BannerViewController.h"
#import <DFPBannerEventHandler.h>
#import <POBBannerView.h>

#define DFP_AU        @"/15671365/pm_sdk/PMSDK-Demo-App-Banner"
#define OW_ADUNIT_ID  @"/15671365/pm_sdk/PMSDK-Demo-App-Banner"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

@interface BannerViewController ()<POBBannerViewDelegate>
@property (nonatomic) POBBannerView *bannerView;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *adSizes = @[ NSValueFromGADAdSize(kGADAdSizeBanner) ];
    
    // Create a banner custom event handler for your ad server. Make sure you use
    // separate event handler objects to create each banner view.
    //For example, The code below creates an event handler for DFP ad server.
    DFPBannerEventHandler *eventHandler = [[DFPBannerEventHandler alloc] initWithAdUnitId:DFP_AU
                                                                             andSizes:adSizes];

    // Create a banner view
    // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
    self.bannerView = [[POBBannerView alloc]
                                 initWithPublisherId:PUB_ID
                                 profileId:PROFILE_ID
                                 adUnitId:OW_ADUNIT_ID
                                 eventHandler:eventHandler];
    // Set the delegate
    self.bannerView.delegate = self;
    
    // Add the banner view to your view hierarchy
    [self addBannerToView:self.bannerView withSize:kGADAdSizeBanner.size];

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
