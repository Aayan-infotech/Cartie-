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
    GMSServices.provideAPIKey("AIzaSyByeL4973jLw5-DqyPtVl79I3eDN4uAuAQ")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
