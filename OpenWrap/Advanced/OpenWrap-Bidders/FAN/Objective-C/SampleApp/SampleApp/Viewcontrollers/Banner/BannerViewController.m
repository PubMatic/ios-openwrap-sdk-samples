

#import "BannerViewController.h"
#import <POBBannerView.h>
#import <POBFANBidder.h>

#define OW_ADUNIT_ID  @"OpenWrapBannerAdUnit"

#define PUB_ID          @"156276"
#define PROFILE_ID      @1165

#define FB_PLACEMENT_ID    @"2526468451010379_2526476071009617"
#define FB_APP_ID          @"2526468451010379"

@interface BannerViewController ()<POBBannerViewDelegate>
@property (nonatomic) POBBannerView *bannerView;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create a banner view
    // For test IDs refer - https://community.pubmatic.com/x/IAI5AQ#TestandDebugYourIntegration-TestProfile/Placement
    self.bannerView = [[POBBannerView alloc] initWithPublisherId:PUB_ID
                                                       profileId:PROFILE_ID
                                                        adUnitId:OW_ADUNIT_ID
                                                         adSizes:@[POBAdSizeMake(320, 50)]];
    // Set the delegate
    self.bannerView.delegate = self;
    
    NSMutableDictionary *custParams = [[NSMutableDictionary alloc] init];
    custParams[POBBidderKey_FB_App_Id] = FB_APP_ID;
    custParams[POBBidderKey_FB_PlacementId] = FB_PLACEMENT_ID;
    custParams[POBBidderKey_BannerAdSize] = POBBannerAdSize320x50;

    // Add bidder
    [self.bannerView addBidderSlotInfo:custParams forBidder:POBBidderIdFAN];
    
    self.bannerView.request.testModeEnabled = YES;

    // Add the banner view to your view hierarchy
    [self addBannerToView:self.bannerView withSize:CGSizeMake(320, 50)];

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
    CGRect rect = bannerView.frame;
    CGSize size = bannerView.creativeSize.cgSize;
    rect.size = size;
    bannerView.frame = rect;
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
