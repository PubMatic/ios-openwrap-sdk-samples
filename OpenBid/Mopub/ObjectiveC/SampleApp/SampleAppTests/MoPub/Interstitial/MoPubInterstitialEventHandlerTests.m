

#import <XCTest/XCTest.h>
#import "MoPubInterstitialEventHandler.h"
#import <MPInterstitialAdController.h>
#import <POBBid.h>
#import <POBRenderer.h>

#define MOPUB_AD_UNIT   @"d77111b8b59b484c8c92cb2e73c204a6"

@interface MoPubInterstitialEventHandler() <MPInterstitialAdControllerDelegate>
@property (nonatomic, strong)   MPInterstitialAdController *interstitial;
@property (nonatomic, weak)     id<POBInterstitialEventDelegate> delegate;
@property (nonatomic, copy)     NSString *adUnitId;
@end

@interface MoPubInterstitialEventHandlerTests : XCTestCase <POBInterstitialEventDelegate>
@property MoPubInterstitialEventHandler *instlEventHandler;
@property XCTestExpectation *expectation;
@end

@implementation MoPubInterstitialEventHandlerTests

- (void)setUp {
    _instlEventHandler = [[MoPubInterstitialEventHandler alloc] initWithAdUnitId:MOPUB_AD_UNIT];                        
    _instlEventHandler.delegate = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInitWithAdUnitId {
    XCTAssertNotNil(_instlEventHandler.adUnitId, @"MoPubInterstitialEventHandlerTests: Failed to set the adUnit");
    XCTAssertNotNil(_instlEventHandler, @"MoPubInterstitialEventHandlerTests: Failed to create MoPubInterstitialEventHandler");
    XCTAssertNotNil(_instlEventHandler.interstitial, @"MoPubInterstitialEventHandlerTests: Failed to create MPInterstitialAdController");
    XCTAssertNotNil(_instlEventHandler.interstitial.delegate, @"MoPubInterstitialEventHandlerTests: Failed to set MPInterstitialAdController delegate");
}


#pragma mark - PMWInterstitialEvent

- (void)testRequestAdWithBid {
    POBBid *bid = [POBBid new];
    [bid setValue:@"105553151321232" forKey:@"impressionId"];
    [bid setValue:@"pubmatic" forKey:@"partner"];
    [bid setValue:@1 forKey:@"status"];
    [_instlEventHandler requestAdWithBid:bid];
    
    XCTAssertNotNil(_instlEventHandler.interstitial.keywords, @"MoPubInterstitialEventHandlerTests: Failed to set keywords");
    XCTAssertNotEqual(_instlEventHandler.interstitial.keywords.length, 0, @"MoPubInterstitialEventHandlerTests: Failed to set keywords");
    XCTAssertNotNil(_instlEventHandler.interstitial.localExtras, @"MoPubInterstitialEventHandlerTests: Failed to set local extras");
}


#pragma mark - MPInterstitialAdControllerDelegate

- (void)testInterstitialDidLoadAd {
    self.expectation = [self expectationWithDescription:@"MoPubInterstitialEventHandlerTests should receive adServerDidWin callback."];
    MPInterstitialAdController *mpInstlController = _instlEventHandler.interstitial;
    [mpInstlController.delegate interstitialDidLoadAd:mpInstlController];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialDidFailToLoadAd {
    self.expectation = [self expectationWithDescription:@"MoPubInterstitialEventHandlerTests should receive failedWithError callback."];
    MPInterstitialAdController *mpInstlController = _instlEventHandler.interstitial;
    [mpInstlController.delegate interstitialDidFailToLoadAd:mpInstlController];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialDidFailToLoadAdWithError {
    self.expectation = [self expectationWithDescription:@"MoPubInterstitialEventHandlerTests should receive failedWithError callback."];
    MPInterstitialAdController *mpInstlController = _instlEventHandler.interstitial;
    [mpInstlController.delegate interstitialDidFailToLoadAd:mpInstlController withError:[NSError new]];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialWillAppear {
    self.expectation = [self expectationWithDescription:@"MoPubInterstitialEventHandlerTests should receive willPresentAd callback."];
    MPInterstitialAdController *mpInstlController = _instlEventHandler.interstitial;
    [mpInstlController.delegate interstitialWillAppear:mpInstlController];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialDidDisappear {
    self.expectation = [self expectationWithDescription:@"MoPubInterstitialEventHandlerTests should receive didDismissAd callback."];
    MPInterstitialAdController *mpInstlController = _instlEventHandler.interstitial;
    [mpInstlController.delegate interstitialDidDisappear:mpInstlController];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

/*
 
 
 - (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
 [self.delegate willPresentAd];
 }
 
 - (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
 [self.delegate didDismissAd];
 }
 */

#pragma mark - PMWInterstitialEventDelegate

- (void)wrapperDidWin {
    
}

- (void)adServerDidWin {
    [self.expectation fulfill];
}

- (void)failedWithError:(NSError *)error {
    [self.expectation fulfill];
}

- (void)willPresentAd {
    [self.expectation fulfill];
}

- (void)didDismissAd {
    [self.expectation fulfill];
}

- (void)willLeaveApp {
}

- (NSDictionary *)customData {
    return nil;
}


- (void)didClickAd {
    
}


- (void)openBidPartnerDidWin {
    
}


@end
