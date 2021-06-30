//
//  AppDelegate.swift
//  Geofence

//
//  Created by Mind on 03/02/18.
//  Copyright © 2018 Mindinventory. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        self.enableLocationServices()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    
    func enableLocationServices() // to check status of locations
    {
        //        locationManager.delegate = self
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            print("status restricted, .denied \(CLLocationManager.authorizationStatus())")
            // Disable location features
            
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            print("status authorizedWhenInUse \(CLLocationManager.authorizationStatus())")
            break
            
        case .authorizedAlways:
            print("status authorizedAlways \(CLLocationManager.authorizationStatus())")
            // Enable any of your app's location features
            
            break
        @unknown default:break;
        }
        
    }

    // MARK:
    // MARK: Fire Local Notifications
    func fireNotification(obj:TblGeofence , isEnter:Bool)
    {
        
        print("notification will be triggered in five seconds..Hold on tight")
        let content = UNMutableNotificationContent()
        content.title = obj.title ?? "TitleMissing"
        content.subtitle = obj.msg! + "at lat = \(obj.latitude) long = \(obj.longitude)"
        content.body = "you are \(isEnter ? "enetr in" : "Exit from") \(obj.title ?? "TitleMissing")"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier:obj.identifier! + "++ \(isEnter ? "1" : "0") \(NSDate.timeIntervalSinceReferenceDate)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription ?? "error in notifications")
            }
        }
    }
    
    
    // MARK:
    // MARK: GeoFance Management
    func registerGeoFance(obj : TblGeofence) {
        
        if locationManager.monitoredRegions.count >= 20 // check current monitored region Apple allowed only 20 at time
        {
            locationManager.stopMonitoring(for: locationManager.monitoredRegions.first!) // if have to add new one then need to remove older then 20 else it will not add new one
        }
        let centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(obj.latitude, obj.longitude)
        let region = CLCircularRegion(center: centerCoordinate, radius: obj.range, identifier: obj.identifier!) // provide radius in meter. also provide uniq identifier for your region.
        region.notifyOnEntry = true // based on your requirements
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region) // to star monitor region
        locationManager.requestState(for: region) // that will check if user is already inside location then it will fire notification instantly.
    }
    
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            
            // Here region.identifier is identifier which you provide during register geofence region.
            // Now you can perform action you want to perfrom. that will same for below didExitRegion method
            
            let geoFance  = (TblGeofence.findOrCreate(dictionary: ["identifier":region.identifier]) as? TblGeofence)!
            if (!(geoFance.title?.isEmpty)!)
            {
                self.fireNotification(obj: geoFance,  isEnter: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            
            let geoFance  = (TblGeofence.findOrCreate(dictionary: ["identifier":region.identifier]) as? TblGeofence)!
            if (!(geoFance.title?.isEmpty)!)
            {
                self.fireNotification(obj: geoFance,  isEnter: false)
            }
            
        }
    }
}

extension AppDelegate:UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
        debugPrint("====================================")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        let strDevides = notification.request.identifier.components(separatedBy: "++ ")
        
        let geoFance  = (TblGeofence.findOrCreate(dictionary: ["identifier":strDevides[0]]) as? TblGeofence)!
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(0))) {
                        let alert = UIAlertController(
                            title: "\(geoFance.title ?? "BlankTitleRecevied")",
                            message: "\(notification.request.content.subtitle) \n \(notification.request.content.body)",
                            preferredStyle: UIAlertController.Style.alert
                        )
            
                        alert.addAction(UIAlertAction(title: "Okey", style: .cancel, handler: { (alert) -> Void in
                            
                        }))
            
                        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            
                    }
        
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == "123456"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
