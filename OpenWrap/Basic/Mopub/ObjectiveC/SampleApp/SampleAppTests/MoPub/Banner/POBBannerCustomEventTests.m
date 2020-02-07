

#import <XCTest/XCTest.h>
#import "POBBannerCustomEvent.h"
#import <POBBid.h>
#import <POBRenderer.h>

@interface POBBannerCustomEvent () <POBAdRendererDelegate>
@property (nonatomic, copy) NSDictionary *localExtras;
@end

@interface POBBannerCustomEventTests : XCTestCase<MPBannerCustomEventDelegate>
@property POBBannerCustomEvent *customEvent;
@property XCTestExpectation *expectation;
@property UIViewController *vc;
@end

@implementation POBBannerCustomEventTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.customEvent = [[POBBannerCustomEvent alloc] init];
    self.customEvent.delegate = self;
    self.customEvent.localExtras = @{@"pob_bid":[POBBid new]};
    _vc = [UIViewController new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.customEvent.delegate = nil;
    self.customEvent = nil;
    self.expectation = nil;
    [super tearDown];
}

- (void)testRequestAdWithSizeAndInfo {
    self.expectation = [self expectationWithDescription:@"Should call didLoadAd callback."];
    [self.customEvent requestAdWithSize:CGSizeMake(320, 50) customEventInfo:@{}];
    id renderer = [POBRenderer bannerRenderer];
    XCTAssertTrue([renderer conformsToProtocol:@protocol(POBBannerRendering)]);
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRendererDidFailToRenderAdWithError {
    self.expectation = [self expectationWithDescription:@"Should receive didFailToLoadAdWithError callback."];
    [self.customEvent rendererDidFailToRenderAdWithError:[NSError new] forDescriptor:[POBBid new]];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRendererWillLeaveApp {
    self.expectation = [self expectationWithDescription:@"Should receive willLeaveApp callback."];
    [self.customEvent rendererWillLeaveApp];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRendererWillPresentModal {
    self.expectation = [self expectationWithDescription:@"Should receive willBeginAction callback."];
    [self.customEvent rendererWillPresentModal];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInterstitialRendererDidDismissModal {
    self.expectation = [self expectationWithDescription:@"Should receive didFinishAction callback."];
    [self.customEvent rendererDidDismissModal];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testViewControllerForPresentingModal {
    UIViewController *presentingVc = [self.customEvent viewControllerForPresentingModal];
    XCTAssertEqual(self.vc, presentingVc, @"Failed to get presenting viewController.");
}

#pragma mark - MPBannerCustomEventDelegate
- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didFailToLoadAdWithError:(NSError *)error {
    [self.expectation fulfill];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didLoadAd:(UIView *)ad {
    NSString *renderedViewClassString = NSStringFromClass([ad class]);
    XCTAssertEqualObjects(renderedViewClassString, @"PMResizableView");
    [self.expectation fulfill];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEvent *)event {
    [self.expectation fulfill];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event {
    [self.expectation fulfill];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEvent *)event {
    [self.expectation fulfill];
}

- (CLLocation *)location { 
    return [[CLLocation alloc] initWithLatitude:44.4 longitude:95.5];
}

- (void)trackClick {
    
}

- (void)trackImpression {
    
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self.vc;
}

@end
