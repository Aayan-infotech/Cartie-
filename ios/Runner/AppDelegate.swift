import UIKit
import Flutter
import GoogleMaps // ✅ Import Google Maps SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // ✅ Register plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // ✅ Initialize Google Maps with your API key
    GMSServices.provideAPIKey("AIzaSyC71kjvJKqTMemfxMek8zBR9Px2T1IB-Ak")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
