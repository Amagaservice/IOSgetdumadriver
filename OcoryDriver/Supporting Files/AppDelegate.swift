//
//  AppDelegate.swift
//  OcoryDriver
//
//  Created by Arun Singh on 09/03/21.
//

import UIKit
import GoogleMaps
import GooglePlaces
import TOCropViewController
import SDWebImage
import iOSDropDown
import IQKeyboardManager
import CoreLocation
import Firebase
import FirebaseMessaging
import UserNotifications
import UserNotificationsUI
import Alamofire


import MapKit
protocol gobackHome {
    func gobackHomeVC(flag: Bool)
}
@main
class AppDelegate: UIResponder, UIApplicationDelegate,UINavigationControllerDelegate {
    static var fcmToken: String?
    var goBackDelegate: gobackHome?
    var locationManager:CLLocationManager!
    var recentToken = Data()
    let gcmMessageId = "ocaryDriver.app"
    let conn = webservices()
    var window: UIWindow?
    var customerData : userCustomerModal?
    var mainViewController = HomeViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        //  GMSServices.provideAPIKey("AIzaSyATS0zIheL0FVRt3QLRQJS6ZFtZGXFrAB0")
        // old
        //  GMSServices.provideAPIKey("AIzaSyA-ks2CpJHvxyKz6TQejEjCGr2xLihH5IA")
        //  GMSPlacesClient.provideAPIKey("AIzaSyDLAHWiWMZsT6uoevKBejTU-gn6vxcczJQ")
        // AIzaSyA-ks2CpJHvxyKz6TQejEjCGr2xLihH5IA
        //new
        GMSServices.provideAPIKey("AIzaSyAJuI_IDQB0lt10U0Obffdr0qFV1soIMh4")
        GMSPlacesClient.provideAPIKey("AIzaSyAJuI_IDQB0lt10U0Obffdr0qFV1soIMh4")
//        GMSServices.provideAPIKey("AIzaSyB-JC40RpeU21Ho_ex_olOh-7Cyi-IuIfQ")
//        GMSPlacesClient.provideAPIKey("AIzaSyDLAHWiWMZsT6uoevKBejTU-gn6vxcczJQ")
//        GMSServices.provideAPIKey("AIzaSyBdt1B9nXt-7R9MancaGUnP6QmCetl_LCE")
//        GMSPlacesClient.provideAPIKey("AIzaSyBdt1B9nXt-7R9MancaGUnP6QmCetl_LCE")

        IQKeyboardManager.shared().isEnabled = true
        self.locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        return true
    }

    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate :  CLLocationManagerDelegate
{

    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
    }

    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Location")
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //Access the last object from locations to get perfect current location
        if let location = locations.last {

            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            NSUSERDEFAULT.setValue("\(myLocation.latitude)", forKey: kCurrentLat)
            NSUSERDEFAULT.setValue("\(myLocation.longitude)", forKey: kCurrentLong)

            geocode(latitude: myLocation.latitude, longitude: myLocation.longitude) { placemark, error in
                
                var userLocationDict = [String : Any]()
                userLocationDict["lat"] = "\(myLocation.latitude)"
                userLocationDict["long"] = "\(myLocation.longitude)"
                print(userLocationDict)
                guard let placemark = placemark, error == nil else { return }
                // you should always update your UI in the main thread
                
                DispatchQueue.main.async {
                    //  update UI here
                    
                    print("address1:", placemark.thoroughfare ?? "")
                    print("address2:", placemark.subThoroughfare ?? "")
                    print("city:",     placemark.locality ?? "")
                    print("state:",    placemark.administrativeArea ?? "")
                    print("zip code:", placemark.postalCode ?? "")
                    print("country:",  placemark.country ?? "")
                    let defaults = UserDefaults.standard
                    let dict = ["address1": placemark.thoroughfare ?? "", "address2": placemark.subThoroughfare ?? "" ,"city" : placemark.locality ?? "","state": placemark.administrativeArea ?? "", "zip code" : placemark.postalCode ?? "","country" : placemark.country ?? "" , "latitude" : myLocation.latitude , "longitude" : myLocation.longitude ] as [String : Any]
                    defaults.set(dict, forKey: "SavedCurrentLocation")
                    
                }
            }
        }
        manager.stopUpdatingLocation()

    }
}
extension AppDelegate : MessagingDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        recentToken = deviceToken
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken ?? ""))")
        
        let tokenFinal = fcmToken ?? ""
        print(tokenFinal)
        NSUSERDEFAULT.setValue(tokenFinal, forKey: kFcmToken)
        Self.fcmToken = tokenFinal
         let dataDict: [String: String] = ["token": fcmToken ?? ""]
         NotificationCenter.default.post(
           name: Notification.Name("FCMToken"),
           object: nil,
           userInfo: dataDict
         )
         // TODO: If necessary send token to application server.
         // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("Received data message: \(remoteMessage.description)")
    }
    
}
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void) {
        let userInfo = notification.request.content.userInfo
        let state = UIApplication.shared.applicationState
        switch UIApplication.shared.applicationState {

          case .active:
              if #available(iOS 14.0, *) {
                  // foreground alertRemoteNotification(request.content.userInfo as NSDictionary) }
                  print("didReceive Method\(userInfo)")
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceiveDataForeground"), object: nil , userInfo: userInfo)
                 // completionHandler(<#UNNotificationPresentationOptions#>)
                  goBackDelegate?.gobackHomeVC(flag: true)
               //   completionHandler([.alert, .badge, .sound])
                  completionHandler([.sound, .list])
              } else {
                  // Fallback on earlier versions
                  completionHandler([.sound])
              }
          default:
              if #available(iOS 14.0, *) {
                  completionHandler([.banner, .sound])
              } else {
                  // Fallback on earlier versions
                  completionHandler([.alert, .sound])
              }
          }

        

    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification Method\(userInfo)")

        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification Method Background\(userInfo)")
        completionHandler(.newData)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let state = UIApplication.shared.applicationState
        if state == .active {
            // foreground alertRemoteNotification(request.content.userInfo as NSDictionary) }
            print("didReceive Method\(userInfo)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceiveDataBackground"), object: nil , userInfo: userInfo)
            completionHandler()
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
    }
}

