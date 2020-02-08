This repository consists of sample applications for PubMatic's OpenWrap SDK integration. You may refer these applications to integrate PubMatic's OpenWrap SDK.

## OpenWrap iOS SDK

Integrate PubMatic OpenWrap SDK into your iOS app to monetize your app inventory using PubMatic's robust platform. With the OpenWrap SDK in your app, you can use the PubMatic platform to control, monitor, and optimize your ad inventory’s financial performance. It enables mobile app developers to maximize their monetization in native iOS applications.

## Documentation

Refer [PubMatic community pages](https://community.pubmatic.com/display/IS/About+iOS+OpenWrap+SDK)
for documentation on using OpenWrap SDK.

## Sample Applications

| Ad Server | Samples |
| ------------- | ------------- |
|   DFP    | [Banner/Interstitial Samples](./OpenWrap/Basic/DFP/) |
|   MoPub    | [Banner/Interstitial Samples](./OpenWrap/Basic/Mopub/) |
|   OpenWrap(Programmatic Only)    | [Banner/Interstitial Samples](./OpenWrap/Basic/NoAdServer/) |
|   Other Ad Server    | [Banner/Interstitial Samples](./OpenWrap/Basic/OtherAdServer/) |


Each iOS sample application includes a Podfile for integrating dependencies.

**Installation steps:**
1. Run `pod install --repo-update` in the same directory where the Podfile is.
1. Open the .xcworkspace file with Xcode and run the app.

See the [CocoaPods Guides](https://guides.cocoapods.org/)
for more information on installing and updating pods.

## Downloads

Please check out [releases](https://github.com/PubMatic/ios-openwrap-sdk-samples/releases)
for the latest downloads of sample apps.

## License

See the [LICENSE](./LICENSE) file.
