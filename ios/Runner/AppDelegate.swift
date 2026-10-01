import UIKit
import google_mobile_ads
import Flutter
import Firebase
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "full", nativeAdFactory: FullLargeNativeAdFactory())
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "large", nativeAdFactory: LargeNativeAdFactory())
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "medium", nativeAdFactory: SmallNativeAdFactory())
     if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

