import Flutter
import UIKit
import Firebase
import UserNotifications  // UNUserNotificationCenter를 사용하기 위해 추가

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // FCM 메시징 델리게이트 설정
    Messaging.messaging().delegate = self

    // UNUserNotificationCenter 델리게이트 설정 및 알림 권한 요청
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      if let error = error {
        print("알림 권한 요청 오류: \(error.localizedDescription)")
      }
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // FCM 토큰 수신 콜백 메서드 (override 키워드 제거)
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("📱 FCM registration token: \(fcmToken ?? "없음")")
    // 여기서 fcmToken을 서버로 전송하거나, 로컬에 저장하는 등 추가 작업을 할 수 있음.
  }

  // 앱이 포그라운드 상태에서 알림을 수신할 때 처리하는 메서드 (override 키워드 제거)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }
}
