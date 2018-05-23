# Geofence
You can setup your own latitude and longitude, and Geofencing notifies your app when the device enters or leaves geographical regions you set up.

It lets you can trigger a notification whenever you enter and leave the restaurant, Shopping center etc. 

In this geofencing tutorial, you will learn how to use region monitoring in iOS with Swift 4.0 – using the Region Monitoring API in Core Location.

Implementation of this code can be used at many places, for example, where the latest and greatest deals whenever favorite shops or restaurant are nearby.

# Requirements
Minimum OS 10.0 and later

# Note
- To test in simulator you can use .GPX file (add GPX file file-> new -> under resource section there will option of GPX file)
- For using GPX file when app is running in simulator there is option in xCode (debug -> simulate location -> select your GPX file)
- In our demo we can use core data for storing region data for testing perpose. so core data model like below.

    
      extension TblGeofence { 
         @nonobjc public class func fetchRequest() -> NSFetchRequest<TblGeofence> {
           return NSFetchRequest<TblGeofence>(entityName: "TblGeofence")
          }

       @NSManaged public var identifier: String?
       @NSManaged public var isFiredOn: Date?
       @NSManaged public var latitude: Double
       @NSManaged public var longitude: Double
       @NSManaged public var msg: String?
       @NSManaged public var range: Double
      @NSManaged public var title: String?

      }


# Manual Installation
1) Firs of setuo Location manager and Location permissions.
          
       class AppDelegate: UIResponder, UIApplicationDelegate {  
       let locationManager = CLLocationManager()
       self.enableLocationServices()
        }
       
2) Next add Following methode in Appdelegate.

        func enableLocationServices() // to check status of locations
        {
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
        }
        
       }
   
3) Now set the delegate of the locationManager instance so that receive the relevant delegate method calls.
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
        
 4) Registering Your Geofences with your location and radios of monitoring region 
          
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
          locationManager.requestState(for: region) // that will check if user is already inside location then it will fire  notification instantly.
         }
         
  5) Next for trigger notification when enter or leave form register region. For this we can use Local Notifications using UNUserNotification framework which have support only iOs 10 or later
  
         func fireNotification(obj:TblGeofence , isEnter:Bool)
    {
        
        print("notification will be triggered in five seconds..Hold on tight")
        let content = UNMutableNotificationContent()
        content.title = obj.title ?? "TitleMissing"
        content.subtitle = obj.msg! + "at lat = \(obj.latitude) long = \(obj.longitude)"
        content.body = "you are \(isEnter ? "enetr in" : "Exit from") \(obj.title ?? "TitleMissing")"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier:obj.identifier! + "++ \(isEnter ? "1" : "0") \(NSDate.timeIntervalSinceReferenceDate)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription ?? "error in notifications")
            }
        }
    }
5) For perfom any action on notification we need to implement UNUserNotificationCenterDelegate

       extension AppDelegate:UNUserNotificationCenterDelegate{
    
           func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
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
                            preferredStyle: UIAlertControllerStyle.alert
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
       
 6) Now we have create one ViewController where we have to add our region manually.   
     - Drag and Drop ViewControlle.swift file in your Projects.
     
# LICENSE!

Geofence is [MIT-licensed](https://github.com/mindinventory/Geofence/blob/master/LICENSE).
     
## Let us know!
We’d be really happy if you send us links to your projects where you use our component. Just send an email to sales@mindinventory.com And do let us know if you have any questions or suggestion regarding our work.
