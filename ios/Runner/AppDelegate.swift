// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  // 엔진을 먼저 준비
  private lazy var flutterEngine = FlutterEngine(name: "gontimetable_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {

    // 1) 엔진 실행
    flutterEngine.run()

    // 2) 플러그인들을 "엔진"에 등록 (self 아님!)
    GeneratedPluginRegistrant.register(with: flutterEngine)

    // 3) 엔진으로 VC 만들고 윈도우에 붙이기
    let flutterVC = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    self.window = UIWindow(frame: UIScreen.main.bounds)
    // --- Safety: eliminate black flash after splash ---
    // Make sure the window and Flutter view show white instead of black
    self.window?.backgroundColor = .white
    flutterVC.view.isOpaque = true
    flutterVC.view.backgroundColor = .white
    // --- end safety ---
    self.window?.rootViewController = flutterVC
    self.window?.makeKeyAndVisible()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}