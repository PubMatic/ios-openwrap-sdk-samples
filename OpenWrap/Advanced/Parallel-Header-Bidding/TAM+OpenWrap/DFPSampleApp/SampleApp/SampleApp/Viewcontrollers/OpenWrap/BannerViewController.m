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

#import "BannerViewController.h"
#import "TAMAdLoader.h"
@import OpenWrapSDK;
@import OpenWrapHandlerDFP;
@import GoogleMobileAds;

// DFP Ad unit id
#define DFP_AU_BANNER          @"/15671365/pm_sdk/A9_Demo"

// PubMatic Ad tag details
#define OW_AU_BANNER           @"/15671365/pm_sdk/PMSDK-Demo-App-Banner"
#define PUB_ID                 @"156276"
#define PROFILE_ID             @1165

// A9 TAM slot id
#define SLOT_UUID   @"5ab6a4ae-4aa5-43f4-9da4-e30755f2b295"

@interface BannerViewController ()<POBBannerViewDelegate,POBBidEventDelegate>
// OpenWrap SDK's banner view
@property (nonatomic) POBBannerView *bannerView;

// OpenWrap SDK's event handler for DFP
@property (nonatomic) DFPBannerEventHandler *eventHandler;

// Bidding manager to manage bids from various bidders. e.g. OpenWrap, TAM
@property (nonatomic) BiddingManager *biddingManager;

// Dictionary to maintain response from different partners
@property (nonatomic) NSMutableDictionary *partnerTargeting;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.partnerTargeting = [NSMutableDictionary new];
    // Initialize bidding manager
    self.biddingManager = [BiddingManager new];
    
    // Set bidding manager delegate
    self.biddingManager.biddingManagerDelegate = self;

    // Register bidders to bidding manager
    [self registerBidders];
    
    // Initialize POBBannerView object
    [self initializeOpenWrapBannerView];

    // Request bidding manager to load bids from all the connected bidders.
    [self.biddingManager loadBids];

    // Load OpenWrap bids
    [self.bannerView loadAd];
}

- (void)registerBidders {
    // You can create other bidders here and register to bidding manager.
    // Add TAM as a bidder
    TAMAdLoader *tamLoader = [[TAMAdLoader alloc] initWithSize:[[DTBAdSize alloc] initBannerAdSizeWithWidth:320 height:50 andSlotUUID:SLOT_UUID]];
    [self.biddingManager registerBidder:tamLoader];
}

- (void)initializeOpenWrapBannerView {
    NSArray *adSizes = @[ NSValueFromGADAdSize(GADAdSizeBanner) ];
    
    // Create a banner custom event handler for your ad server. Make sure you use
    // separate event handler objects to create each banner view.
    //For example, The code below creates an event handler for DFP ad server.
    self.eventHandler = [[DFPBannerEventHandler alloc] initWithAdUnitId:DFP_AU_BANNER andSizes:adSizes];
    
    // Set config block on event handler instance
    __weak typeof(self) weakSelf = self;
    [self.eventHandler setConfigBlock:^(GAMBannerView *view, GAMRequest *request, POBBid *bid) {
        NSMutableDictionary * customTargeting = [NSMutableDictionary dictionaryWithDictionary:request.customTargeting];
        for (NSString *key in weakSelf.partnerTargeting) {
            [customTargeting addEntriesFromDictionary:[weakSelf.partnerTargeting valueForKey:key]];
        }
        request.customTargeting = [NSDictionary dictionaryWithDictionary:customTargeting];
        [weakSelf.partnerTargeting removeAllObjects];
        [weakSelf log:@"Successfully added targeting from all bidders"];
    }];
    // Create a banner view
    self.bannerView = [[POBBannerView alloc]
                       initWithPublisherId:PUB_ID
                       profileId:PROFILE_ID
                       adUnitId:OW_AU_BANNER
                       eventHandler:_eventHandler];
    
    self.bannerView.delegate = self;
    
    self.bannerView.bidEventDelegate = self;

    // Add the banner view to your view hierarchy
    [self addBannerToView:self.bannerView withSize:CGSizeMake(320, 50)];
}

#pragma mark - Banner view delegate methods
// Provides a view controller to use for presenting model views
- (UIViewController *)bannerViewPresentationController {
    return self;
}

// Notifies the delegate that an ad has been successfully loaded and rendered.
- (void)bannerViewDidReceiveAd:(POBBannerView *)bannerView {
    [self log:@"Banner : Ad received with size %@ ", bannerView.creativeSize];
    /*!
     OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
     To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
    */
    [self.biddingManager loadBids];
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)bannerView:(POBBannerView *)bannerView
didFailToReceiveAdWithError:(NSError *)error {
    [self log:@"Banner : Ad failed with error : %@", [error localizedDescription]];
    /*!
     OpenWrap SDK will start refresh loop internally as soon as ad rendering succeeds/fails.
     To include other ad servers' bids in next refresh cycle, call loadBids on bidding manager.
    */
    [self.biddingManager loadBids];
}

// Notifies the delegate whenever current app goes in the background due to user click
- (void)bannerViewWillLeaveApplication:(POBBannerView *)bannerView {
    [self log:@"Banner : Will leave app"];
}

// Notifies the delegate that the banner ad view will launch a modal on top of the current view controller, as a result of user interaction.
- (void)bannerViewWillPresentModal:(POBBannerView *)bannerView {
    [self log:@"Banner : Will present modal"];
}

// Notifies the delegate that the banner ad view has dismissed the modal on top of the current view controller.
- (void)bannerViewDidDismissModal:(POBBannerView *)bannerView {
    [self log:@"Banner : Dismissed modal"];
}

// Notifies the delegate that the banner view was clicked.
- (void)bannerViewDidClickAd:(POBBannerView *)bannerView {
    [self log:@"Banner : Ad clicked"];
}

// Notifies the delegate that an ad impression has been recorded.
- (void)bannerViewDidRecordImpression:(POBBannerView *)bannerView {
    [self log:@"Banner : Ad Impression"];
}

#pragma mark - Bid event delegate methods
- (void)bidEvent:(id<POBBidEvent>)bidEventObject didReceiveBid:(POBBid *)bid {
    [self log:@"Banner : Did receive bid"];
    // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
    // Notify bidding manager that OpenWrap's success response is received.
    [self.biddingManager notifyOpenWrapBidEvent];
}

- (void)bidEvent:(id<POBBidEvent>)bidEventObject didFailToReceiveBidWithError:(NSError *)error {
    [self log:@"Banner : Did fail to receive bid with error - POBError{errorCode=%ld, errorMessage='%@'}", error.code, error.localizedDescription];

    // Notify bidding manager that OpenWrap's failure response is received.
    [self.biddingManager notifyOpenWrapBidEvent];
}

#pragma mark - BiddingManagerDelegate Methods
- (void)didReceiveResponse:(NSDictionary *)response {
    /*!
     This method will be invoked as soon as responses from all the bidders are received.
     Here, client side auction can be performed between the bids available in response dictionary.
     To send the bids' targeting to DFP, add targeting from received response in
     partnerTargeting dictionary. This will be sent to DFP request using config block,
     Config block will be called just before making an ad request to DFP.
     */
    [self.partnerTargeting addEntriesFromDictionary:response];
    [self.bannerView proceedToLoadAd];
}

- (void)didFailToReceiveResponse:(NSError *)error {
    /*!
     No response is available from other bidders, so no need to do anything.
     Just call proceedToLoadAd. OpenWrap SDK will have it's response saved internally
     so it can proceed accordingly.
     */
    [self log:@"No targeting received from any bidder"];
    [self.bannerView proceedToLoadAd];
}

#pragma mark - dealloc
- (void)dealloc {
    _bannerView = nil;
}

- (void)addBannerToView:(UIView *)bannerView withSize:(CGSize )size{
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    
    [bannerView.heightAnchor constraintEqualToConstant:size.height].active = YES;
    [bannerView.widthAnchor constraintEqualToConstant:size.width].active = YES;

    if (@available(iOS 11.0, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [bannerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
        [bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [bannerView.bottomAnchor constraintEqualToAnchor:margins.topAnchor].active = YES;
        [bannerView.centerXAnchor constraintEqualToAnchor:margins.centerXAnchor].active = YES;
    }
}

@end
