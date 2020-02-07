

#import <XCTest/XCTest.h>
#import "POBInterstitialCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBInterstitialCustomEvent () <POBInterstitialRendererDelegate>
@property (nonatomic, weak) id<POBInterstitialRendering> currentRenderer;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, copy) NSDictionary *localExtras;
@end

@interface POBInterstitialCustomEventTests : XCTestCase <MPInterstitialCustomEventDelegate>
@property POBInterstitialCustomEvent *customEvent;
@property XCTestExpectation *expectation;
@property BOOL isWillAppearFired;
@property BOOL isWillDisappearFired;
@end

@implementation POBInterstitialCustomEventTests

- (void)setUp {
    self.customEvent = [[POBInterstitialCustomEvent alloc] init];
    self.customEvent.delegate = self;
    self.customEvent.localExtras = @{@"pob_bid":[POBBid new]};
}

- (void)tearDown {
    self.customEvent.delegate = nil;
    self.customEvent = nil;
    self.expectation = nil;
}

- (void)testRequestInterstitialWithCustomEventInfo {
    [self.customEvent requestInterstitialWithCustomEventInfo:[NSDictionary new]];
    XCTAssertNotNil(self.customEvent.currentRenderer, @"PMInterstitialCustomEventTests: Failed to create renderer.");
}

- (void) testShowInterstitialFromRootViewController {
    [self.customEvent requestInterstitialWithCustomEventInfo:[NSDictionary new]];
    [self.customEvent showInterstitialFromRootViewController:[UIViewController new]];
    XCTAssertNotNil(self.customEvent.currentRenderer, @"PMInterstitialCustomEventTests: Failed to get the renderer.");
}

#pragma mark - PMInterstitialRendererDelegate

- (void)testInterstitialRendererDidRenderAd {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should to get didLoadAd callback."];
    [self.customEvent interstitialRendererDidRenderAd];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererDidFailToRenderAdWithError {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should receive didFailToLoadAdWithError callback."];
    [self.customEvent interstitialRendererDidFailToRenderAdWithError:[NSError new]];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererDidClick {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should receive DidReceiveTapEvent callback."];
    [self.customEvent interstitialRendererDidClick];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererWillLeaveApp {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should receive WillLeaveApp callback."];
    [self.customEvent interstitialRendererWillLeaveApp];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererWillPresentModal {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should receive WillAppear and DidAppear callback."];
    [self.customEvent interstitialRendererWillPresentModal];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererDidDismissModal {
    self.expectation = [self expectationWithDescription:@"PMInterstitialCustomEventTests should receive WillDisappear and DidDisappear callback."];
    [self.customEvent interstitialRendererDidDismissModal];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testViewControllerForPresentingModal {
    UIViewController *newVc = [UIViewController new];
    [self.customEvent showInterstitialFromRootViewController:newVc];
    UIViewController *presentingVc = [self.customEvent viewControllerForPresentingModal];
    XCTAssertEqual(newVc, presentingVc, @"PMInterstitialCustomEventTests: Failed to get presenting viewController.");
}

#pragma mark - MPInterstitialCustomEventDelegate

- (CLLocation *)location {
    return nil;
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
                      didLoadAd:(id)ad {
    [self.expectation fulfill];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
       didFailToLoadAdWithError:(NSError *)error {
    [self.expectation fulfill];
}

- (void)interstitialCustomEventDidExpire:(MPInterstitialCustomEvent *)customEvent {
    
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent {
    _isWillAppearFired = YES;
}

- (void)interstitialCustomEventDidAppear:(MPInterstitialCustomEvent *)customEvent {
    if (_isWillAppearFired) {
        [self.expectation fulfill];
    }
}

- (void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEvent *)customEvent {
    _isWillDisappearFired = YES;
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent {
    if (_isWillDisappearFired) {
        [self.expectation fulfill];
    }
}

- (void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEvent *)customEvent {
    [self.expectation fulfill];
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent {
    [self.expectation fulfill];
}

- (void)trackImpression {
}

- (void)trackClick {
}

@end
