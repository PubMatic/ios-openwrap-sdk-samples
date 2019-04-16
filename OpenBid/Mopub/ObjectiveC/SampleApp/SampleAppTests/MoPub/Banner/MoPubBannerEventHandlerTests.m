

#import <XCTest/XCTest.h>
#import "MoPubBannerEventHandler.h"
#import <MPAdView.h>
#import <POBBid.h>
#import <POBRenderer.h>

#define MOPUB_AD_UNIT  @"7dd627733dab46d19755fb2da299b8c7"

@interface MoPubBannerEventHandler() <MPAdViewDelegate>
@property (nonatomic, strong) MPAdView *bannerView;
@property (nonatomic, weak)     id<POBBannerEventDelegate> delegate;
@property (nonatomic, copy)     NSString *adUnitId;
@end

@interface MoPubBannerEventHandlerTests : XCTestCase<POBBannerEventDelegate>
@property MoPubBannerEventHandler *eventHandler;
@property XCTestExpectation *expectation;
@property UIViewController *vc;
@end

@implementation MoPubBannerEventHandlerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _eventHandler = [[MoPubBannerEventHandler alloc] initWithAdUnitId:MOPUB_AD_UNIT adSize:MOPUB_BANNER_SIZE];
    [self.eventHandler setDelegate:self];
    _vc = [UIViewController new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _eventHandler = nil;
    [super tearDown];
}

- (void)testInitWithAdUnitId {
    XCTAssertNotNil(self.eventHandler, @"MoPubBannerEventHandlerTests: Failed to create MoPubbannerEventHandler");
    XCTAssertNotNil(self.eventHandler.bannerView, @"MoPubBannerEventHandlerTests: Failed to create MPAdView");
    XCTAssertNotNil(self.eventHandler.bannerView.delegate, @"MoPubBannerEventHandlerTests: Failed to set MPAdViewDelegate");
}

#pragma mark - PMWBannerEvent
- (void)testRequestAdWithBid {
    POBBid *bid = [POBBid new];
    [bid setValue:@"105553151321232" forKey:@"impressionId"];
    [bid setValue:@"wdeal" forKey:@"dealId"];
    [bid setValue:@"pubmatic" forKey:@"partner"];
    [bid setValue:@1 forKey:@"status"];
    [bid setValue:@1 forKey:@"price"];
    [self.eventHandler requestAdWithBid:bid];
    
    XCTAssert(self.eventHandler.bannerView.keywords.length != 0, @"MoPubBannerEventHandlerTests: Failed to set keywords");
    XCTAssertTrue([self.eventHandler.bannerView.keywords containsString:kWDealIdKey]);
    XCTAssertTrue([self.eventHandler.bannerView.keywords containsString:kBidIdKey]);
    XCTAssertTrue([self.eventHandler.bannerView.keywords containsString:kBidPriceKey]);
    XCTAssertTrue([self.eventHandler.bannerView.keywords containsString:kBidStatusKey]);
    XCTAssertTrue([self.eventHandler.bannerView.keywords containsString:kBidPartnerKey]);
    XCTAssertNotNil(self.eventHandler.bannerView.localExtras, @"MoPubBannerEventHandlerTests: Failed to set local extras");
    XCTAssertTrue([self.eventHandler.bannerView.localExtras[@"pob_bid"] isKindOfClass:[POBBid class]]);
}

- (void)testAdServerDidWin {
    self.expectation = [self expectationWithDescription:@"Should receive adServerDidWin callback."];
    MPAdView *bannerAdView = self.eventHandler.bannerView;
    [bannerAdView.delegate adViewDidLoadAd:bannerAdView];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFailedWithError {
    self.expectation = [self expectationWithDescription:@"Should receive ad failed callback."];
    MPAdView *bannerAdView = self.eventHandler.bannerView;
    [bannerAdView.delegate adViewDidFailToLoadAd:bannerAdView];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testWillPresentModal {
    self.expectation = [self expectationWithDescription:@"Should receive willPresentModal callback."];
    MPAdView *bannerAdView = self.eventHandler.bannerView;
    [bannerAdView.delegate willPresentModalViewForAd:bannerAdView];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testDidDismissModalViewForAd {
    self.expectation = [self expectationWithDescription:@"Should receive didDismissModal callback."];
    MPAdView *bannerAdView = self.eventHandler.bannerView;
    [bannerAdView.delegate didDismissModalViewForAd:bannerAdView];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testWillLeaveApp {
    self.expectation = [self expectationWithDescription:@"Should receive willLeaveApp callback."];
    MPAdView *bannerAdView = self.eventHandler.bannerView;
    [bannerAdView.delegate willLeaveApplicationFromAd:bannerAdView];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testViewControllerForPresentingModal {
    XCTAssertEqualObjects(self.eventHandler.bannerView.delegate.viewControllerForPresentingModalView, self.vc);
}

#pragma mark - PMWBannerEventDelegate
- (void)adServerDidWin:(UIView *)view {
    [self.expectation fulfill];
}

- (void)didDismissModal {
    [self.expectation fulfill];
}

- (void)failedWithError:(NSError *)error {
    [self.expectation fulfill];
}

- (UIViewController *)viewControllerForPresentingModal {
    return self.vc;
}

- (void)willLeaveApp {
    [self.expectation fulfill];
}

- (void)willPresentModal {
    [self.expectation fulfill];
}

- (void)openBidPartnerDidWin {
    
}


- (void)wrapperDidWin {
    [self.expectation fulfill];
}

@end
