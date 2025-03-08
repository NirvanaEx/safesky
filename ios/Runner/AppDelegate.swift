import UIKit
import Flutter
import CoreLocation  // Добавьте этот импорт

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {  // Реализуем протокол
  let locationManager = CLLocationManager()  // Создаем менеджер локации

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Настройка для фоновых обновлений локации
    locationManager.delegate = self
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
