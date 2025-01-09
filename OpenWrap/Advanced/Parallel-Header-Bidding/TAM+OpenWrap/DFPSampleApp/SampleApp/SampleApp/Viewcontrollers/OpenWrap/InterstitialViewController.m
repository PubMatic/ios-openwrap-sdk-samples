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
#import "InterstitialViewController.h"
#import "TAMAdLoader.h"
@import OpenWrapSDK;
@import OpenWrapHandlerDFP;
@import GoogleMobileAds;

// DFP Ad unit id
#define DFP_AU        @"/15671365/pm_sdk/A9_Demo"

// PubMatic Ad tag details
#define OW_ADUNIT_ID  @"/15671365/pm_sdk/PMSDK-Demo-App-Interstitial"
#define PUB_ID        @"156276"
#define PROFILE_ID    @1165

// A9 TAM slot id
#define SLOT_UUID     @"4e918ac0-5c68-4fe1-8d26-4e76e8f74831"

@interface InterstitialViewController ()<POBInterstitialDelegate, POBBidEventDelegate>
// OpenWrap SDK's interstitial view
@property (nonatomic) POBInterstitial *interstitial;
@property (nonatomic) IBOutlet UIButton *showAdButton;

// OpenWrap SDK's event handler for DFP
@property (nonatomic) DFPInterstitialEventHandler *eventHandler;

// Bidding manager to manage bids from various bidders. e.g. OpenWrap, TAM
@property (nonatomic) BiddingManager *biddingManager;

// Dictionary to maintain response from different partners
@property (nonatomic) NSMutableDictionary *partnerTargeting;
@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.partnerTargeting = [NSMutableDictionary new];
    // Initialize bidding manager
    self.biddingManager = [BiddingManager new];

    // Set bidding manager delegate
    self.biddingManager.biddingManagerDelegate = self;

    // Register bidders to bidding manager
    [self registerBidders];

    // Initialize POBInterstitial object
    [self initializeInterstitial];
}

- (void)registerBidders {
    // You can create other bidders here and register to bidding manager.
    // Add TAM bidder
    TAMAdLoader *tamLoader = [[TAMAdLoader alloc] initWithSize:[[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:SLOT_UUID]];
    [self.biddingManager registerBidder:tamLoader];
}

- (void)initializeInterstitial {
    // Create an interstitial custom event handler for your ad server. Make
    // sure you use separate event handler objects to create each interstitial
    // For example, The code below creates an event handler for DFP ad server.
    self.eventHandler = [[DFPInterstitialEventHandler alloc] initWithAdUnitId:DFP_AU];
    
    // Set config block on event handler instance
    __weak typeof(self) weakSelf = self;
    [self.eventHandler setConfigBlock:^(GAMRequest *request, POBBid *bid) {
        NSMutableDictionary * customTargeting = [NSMutableDictionary dictionaryWithDictionary:request.customTargeting];
        for (NSString *key in weakSelf.partnerTargeting) {
            [customTargeting addEntriesFromDictionary:[weakSelf.partnerTargeting valueForKey:key]];
        }
        request.customTargeting = [NSDictionary dictionaryWithDictionary:customTargeting];
        [weakSelf.partnerTargeting removeAllObjects];
        NSLog(@"Successfully added targeting from all bidders");
    }];

    self.interstitial = [[POBInterstitial alloc]
                         initWithPublisherId:PUB_ID
                         profileId:PROFILE_ID
                         adUnitId:OW_ADUNIT_ID
                         eventHandler:self.eventHandler];

    // Set the delegate
    self.interstitial.delegate = self;

    // Set the bid event delegate
    self.interstitial.bidEventDelegate = self;
}

#pragma mark - Load and Show button action methods
- (IBAction)loadAdAction:(id)sender {
    // Load bids from other partners (e.g. TAM)
    [self.biddingManager loadBids];

    // Load OpenWrap bids
    [self.interstitial loadAd];
}

- (IBAction)showAdAction:(id)sender {
    if (self.interstitial.isReady) {
        // Show interstitial ad
        [self.interstitial showFromViewController:self];
    }
}

#pragma mark - POBInterstitialDelegate
// Notifies the delegate that an ad has been received successfully.
- (void)interstitialDidReceiveAd:(nonnull POBInterstitial *)interstitial {
    self.showAdButton.hidden = NO;
    NSLog(@"Interstitial : Ad Received");
}

// Notifies the delegate of an error encountered while loading or rendering an ad.
- (void)interstitial:(nonnull POBInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Interstitial : Failed to receive ad with error - POBError{errorCode=%ld, errorMessage='%@'}", (long)error.code, error.localizedDescription);
}

// Notifies the delegate of an error encountered while showing an ad.
- (void)interstitial:(POBInterstitial *)interstitial didFailToShowAdWithError:(NSError *)error {
    NSLog(@"Interstitial : Failed to show ad with error - POBError{errorCode=%ld, errorMessage='%@'}", (long)error.code, error.localizedDescription);
}

// Notifies the delegate that the interstitial ad will be presented as a modal on top of the current view controller.
- (void)interstitialWillPresentAd:(POBInterstitial * _Nonnull)interstitial {
    NSLog(@"Interstitial : Will present");
}

- (void)interstitialDidPresentAd:(POBInterstitial *)interstitial {
    NSLog(@"Interstitial : Did present");
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

#pragma mark - Bid event delegate methods
- (void)bidEvent:(id<POBBidEvent>)bidEventObject didReceiveBid:(POBBid *)bid {
    NSLog(@"Interstitial : Did receive bid");
    // No need to pass OW's targeting info to bidding manager, as it will be passed to DFP internally.
    // Notify bidding manager that OpenWrap's success response is received.
    [self.biddingManager notifyOpenWrapBidEvent];
}

- (void)bidEvent:(id<POBBidEvent>)bidEventObject didFailToReceiveBidWithError:(NSError *)error {
    NSLog(@"Interstitial : Did fail to receive bid with error - POBError{errorCode=%ld, errorMessage='%@'}", error.code, error.localizedDescription);

    // Notify bidding manager that OpenWrap's failure response is received.
    [self.biddingManager notifyOpenWrapBidEvent];
}

#pragma mark - BiddingManagerDelegate Methods
- (void)didReceiveResponse:(NSDictionary *)response {
    /*!
     This method will be invoked as soon as responses from all the bidders are received.
     Here, client side auction can be performed between the bids available in response dictionary.
     
     To send the bids targeting to DFP, add targeting from received response in partnerTargeting dictionary. This will be sent to DFP request using config block.
     Config block will be called just before making an ad request to DFP.
     */
    [self.partnerTargeting addEntriesFromDictionary:response];
    [self.interstitial proceedToLoadAd];
}

- (void)didFailToReceiveResponse:(NSError *)error {
    /*!
     No response is available from other bidders, so no need to do anything.
     Just call proceedToLoadAd. OpenWrap SDK will have it's response saved internally
     so it can proceed accordingly.
     */
    NSLog(@"No targeting received from any bidder");
    [self.interstitial proceedToLoadAd];
}

#pragma mark - dealloc
- (void)dealloc {
    self.interstitial = nil;
}
@end


