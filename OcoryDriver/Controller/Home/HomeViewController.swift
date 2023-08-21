//
//  HomeViewController.swift
//  OcoryDriver
//
//  Created by Arun Singh on 12/03/21.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import AVFoundation
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController {
    //MARK:- OUTLETS
    @IBOutlet var mUserNAme: UILabel!
    @IBOutlet weak var mTotalEarning: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var confirmationView: SetView!
    @IBOutlet weak var fromAddressLbl: UILabel!
    @IBOutlet weak var toAddressLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var totalFareLbl: UILabel!
    @IBOutlet weak var accptRejectView: UIView!
    @IBOutlet weak var startRideView: UIView!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var offlineOnlineBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var ServicesView: UIView!
    @IBOutlet weak var servicesList: UITableView!
    @IBOutlet weak var mDocumentPendingView: UIView!
    @IBOutlet weak var serviceHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mExpireVehicle: UIView!
    var locationManager: CLLocationManager!
    var marker = GMSMarker()
    var update = true
    var customerData : userCustomerModal?
    var profileDetails : ProfileData?
    let conn = webservices()
    var acceptRejectViewCase = acceptReject.acceptStatus
    var arrayPolyline = [GMSPolyline]()
    var startLOC = CLLocation()
    var endLOC = CLLocation()
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var toggleState = 1
    
    var recordSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var settings = [String : Int]()
    var onOffStatus = onOff.online
    var selectServicesStatus = selectServices.isNotSelected
    var onOffValue = ""
    weak var timer: Timer?
    var pendingReqData = [RidesData]()
    var pendingRideId = ""
    var isChecked = true
    // Bool property
    var  checkBtnStatusServices = false
    var selectedIndexServices  = 0
    var servicesData = [ServicesModel]()
    var  checkBtnStatus = false
    var selectedIndex  = 0
    var vehicleTypeId = ""
    var vehicleTypeStatus = ""
    var arrSelectedRows:[IndexPath] = []
    var arrSelectedRowsStatus:[String] = []
    var rowsWhichAreChecked = [NSIndexPath]()
    var arrSelectedRowsNew:[Int] = []
    var arrnotSelectedRowsNew:[Int] = []
    //  let my_switch = UISwitch(frame: .zero)
    var selectedRows:[IndexPath] = []
    // toggalswitch
    var toggalBTN = ""
    var change_vehicle = ""
    var Doc_Exp = ""
    var Doc_Pend = ""
    var progressTimer: Timer?
    var trackYN = ""
    var navYN = ""

    @IBOutlet weak var amountLblFinal: UILabel!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var my_switch: UISwitch!
    @IBOutlet weak var offlineOnlineLabel: UILabel!
    @IBOutlet weak var mOnoffToggalBTN: UIButton!
    @IBOutlet weak var mactionRLBL: UILabel!
    
    var arr = ["Pending","Pending","Pending","Pending","Pending","Pending"]
    var lastRideData : LastRideModal?
    var pendingLastRideStatus = false
    let dispatchGroup = DispatchGroup()
    var section = ["",""]
   // var progressTimer = Timer()
    var counter: Int = 0;
    var total: Int = 40;
    weak var timerr: Timer?
    var appMovedToForegroundStatus = false
    //MARK:- Variables
    var ref: DatabaseReference!
   
    var currentLocation: CLLocation!
    var timerL : Timer?
    var locManager : CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppVersionPopup()
        self.registerCell()
        self.mDocumentPendingView.isHidden = true
        self.mExpireVehicle.isHidden = true
        self.mDocumentPendingView.layer.cornerRadius = 5
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        paymentView.isHidden = true
        ServicesView.isHidden = true
        progressView.progress = 0.0
        //  self.my_switch.isUserInteractionEnabled = true
        if let savedPeople = UserDefaults.standard.object(forKey: "loginInfo") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [String: Any] {
                print("Local Saved Login Data====\(decodedPeople)")
                if let user_id = decodedPeople["user_id"] as? String {
                    NSUSERDEFAULT.set(user_id, forKey: kUserID)
                }
                if let fcm = decodedPeople["gcm_token"] as? String {
                    NSUSERDEFAULT.set(fcm, forKey: kFcmToken )
                    print("GCM TOKEN IS HERE \(NSUSERDEFAULT.value(forKey: kFcmToken) ?? "")")
                }
            }
        }
        print(NSUSERDEFAULT.value(forKey: accessToken))
        print("FCM TOKEN IS HERE \(NSUSERDEFAULT.value(forKey: kFcmToken) ?? "")")
        self.setNavButton()
        self.mapView.isMyLocationEnabled = true
        self.setUpLocation()
      //  self.setUpAudioRecording()
        NotificationCenter.default.addObserver(self, selector: #selector(loadBackgroundList), name: NSNotification.Name(rawValue: "ReceiveDataBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadForegroundList), name: NSNotification.Name(rawValue: "ReceiveDataForeground"), object: nil)
        self.appMovedToForegroundStatus = true
        getearning()
        getdocumentaApi()
        logoutAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NSUSERDEFAULT.set("no", forKey: checknotifi)
        print("ViewWILLappear call")
        //KKself.appUpdateAvailable()
        let onOffTap = NSUSERDEFAULT.value(forKey: kUpdateDriveStatus) as? String
        if onOffStatus == onOff.online  &&   onOffTap == "1" {
            onOffValue = "Online"
            offlineOnlineLabel.text = "Online"
            my_switch.isOn = true
            my_switch.onTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            self.updateStatus(updateStatus: "1")
            NSUSERDEFAULT.set("1", forKey: kUpdateDriveStatus)
            offlineOnlineBtn.setTitle("Online", for: .normal)
            offlineOnlineBtn.backgroundColor = UIColor(named: "green")
            getLastRideDataApi()
        }
        else{
            offlineOnlineBtn.setTitle("Offline", for: .normal)
            offlineOnlineBtn.backgroundColor = UIColor.red
            onOffValue = "Offline"
            offlineOnlineLabel.text = "Offline"
            my_switch.isOn = false
            my_switch.onTintColor = UIColor.clear
            self.updateStatus(updateStatus: "3")
            NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
        }
        
        DispatchQueue.main.async {
            self.timerL = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
                self.UpdateLotLng()
              //  self.checkonline()
            }
        }
        DispatchQueue.main.async {
            print("FIRST")
            NavigationManager.pushToLoginVC(from: self)
        }
        
       
        DispatchQueue.main.async {
            self.timerL = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
             //   self.UpdateLotLng()
                self.checkonline()
            }
        }
        DispatchQueue.main.async {
            print("FIRST")
            self.getProfileDataApi()
        }
        DispatchQueue.main.async {
            print("SECOND")
         self.getSelectServicesApi()
        }
        DispatchQueue.main.async {
            print("THIRD")
            self.pendingRequestApi()
        }
        
    }
    // MARK: Check AppVersion
      func updateAppVersionPopup(){
        _ = try? VersionCheck.shared.isUpdateAvailable { (update, error) in
          DispatchQueue.main.async {
            if let error = error {
              print(error)
            } else if let update = update {
              print("update12",update)
              if update == true {
                  let refreshAlert = UIAlertController(title: Singleton.shared!.title , message: "Please update new version", preferredStyle: UIAlertController.Style.alert)
                  refreshAlert.addAction(UIAlertAction(title: "UPDATE", style: .destructive, handler: { (action: UIAlertAction!) in
                      self.openAppStore()
                  }))
                  refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                  }))
                  self.present(refreshAlert, animated: true, completion: nil)
//                  upgradeAvailable = true
//                  versionAvailable = version
              }
            }
          }
        }
      }
    func logoutAPI(){
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "updateloginlogout", params: ["status" : 1], authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
            //    self.logO()
            }
        }
    }
    
//    @objc func updateLAt() {
//      //  if kRideId != ""{
//            UpdateLotLng()
//     //   }
//    }
    
    //MARK:- update and left
    func UpdateLotLng(){
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        locManager.allowsBackgroundLocationUpdates = true
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
     //   locManager.allowsBackgroundLocationUpdates = true
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locManager.location else {
                return
            }
            let LatitudeGPS = String(format: "%.10f", locManager.location!.coordinate.latitude)
            let LongitudeGPS = String(format: "%.10f", locManager.location!.coordinate.longitude)
            let speedGPS = String(format: "%.3f", locManager.location!.speed)
            let Altitude = String(format: "%.3f", locManager.location!.altitude)
        //    let Course = String(format: "%.3f", locManager.location!.course)
            print("loc update")
            
//            DispatchQueue.main.async {
//                print("FIRST")
//                self.checkdevicetokenAPI()
//            }
//
            let currentLocationLat = currentLocation.coordinate.latitude as! Double
            let currentLocationLng = currentLocation.coordinate.longitude as! Double
            
            kCurrentLocaLat = LatitudeGPS
            kCurrentLocaLong = LongitudeGPS
            var location = locManager.location
            let time = location?.timestamp.timeIntervalSinceReferenceDate as! Double
       
            let speedAccuracyMetersPerSecond = location?.speedAccuracy as! Double
            var accuracy = Double()
            if #available(iOS 13.4, *) {
                 accuracy = location?.courseAccuracy as! Double
            } else {
                accuracy = 0.0
                // Fallback on earlier versions
            }
            let verticalAccuracyMeters = location?.verticalAccuracy as! Double
            if kRideId != ""{
                self.ref = Database.database().reference()
                
                let dict:Dictionary<String, Any>? = ["accuracy": accuracy,
                                                     "bearing" : 0,
                                                     "bearingAccuracyDegrees" : 0,
                                                     "complete" : true,
                                                     "fromMockProvider" : false,
                                                     "provider": "fused",
                                                     "speedAccuracyMetersPerSecond": speedAccuracyMetersPerSecond,
                                                     "verticalAccuracyMeters":verticalAccuracyMeters,
                                                     "elapsedRealtimeNanos": 0,
                                                     "elapsedRealtimeUncertaintyNanos": 0,
                                                     "latitude": currentLocationLat,
                                                     "longitude": currentLocationLng,
                                                     "altitude":Altitude,
                                                     "speed":speedGPS,
                                                     "time":time]
                print(dict!)
                let name = NSUSERDEFAULT.value(forKey: kName) as? String ?? ""
                //  self.ref?.child("rides").childByAutoId().child(kRideId).setValue(dict)
                
                let refs = self.ref?.child("rides").child(name + kRideId).child(kRideId).setValue(dict)
                //   let refs = self.ref.child(name + kRideId).child(kRideId)
                //    refs.setValue(dict)
                print(ref)
                print(refs)
                
            }
        }
    }
    
    //MARK:- check online offline status
    func checkonline(){
        let onOffTap = NSUSERDEFAULT.value(forKey: kUpdateDriveStatus) as? String
        let checked = NSUSERDEFAULT.value(forKey: checknotifi) as? String
        if onOffTap == "1" && checked == "no"{
            getLastRideDataApi()
        }
    }
    
//    func appUpdateAvailable() -> (Bool,String?) {
//            
//            guard let info = Bundle.main.infoDictionary,
//                  let identifier = info["CFBundleIdentifier"] as? String else {
//                return (false,nil)
//            }
//            
//    //        let storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=\(identifier)&country=IN"
//            let storeInfoURL:String = "https://itunes.apple.com/in/lookup?bundleId=com.getdumadriver.app"
//            var upgradeAvailable = false
//            var versionAvailable = ""
//            // Get the main bundle of the app so that we can determine the app's version number
//            let bundle = Bundle.main
//            if let infoDictionary = bundle.infoDictionary {
//                // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
//                let urlOnAppStore = NSURL(string: storeInfoURL)
//                if let dataInJSON = NSData(contentsOf: urlOnAppStore! as URL) {
//                    // Try to deserialize the JSON that we got
//                    if let dict: NSDictionary = try? JSONSerialization.jsonObject(with: dataInJSON as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject] as NSDictionary? {
//                        if let results:NSArray = dict["results"] as? NSArray {
//                            if let version = (results[0] as! [String:Any])["version"] as? String {
//                                // Get the version number of the current version installed on device
//                                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
//                                    // Check if they are the same. If not, an upgrade is available.
//                                    print("\(version)")
//                                    if version != currentVersion {
//                                        let refreshAlert = UIAlertController(title: Singleton.shared!.title , message: "Please update new version", preferredStyle: UIAlertController.Style.alert)
//                                        refreshAlert.addAction(UIAlertAction(title: "UPDATE", style: .destructive, handler: { (action: UIAlertAction!) in
//                                            self.openAppStore()
//                                        }))
//                                        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//                                        }))
//                                       present(refreshAlert, animated: true, completion: nil)
//                                        upgradeAvailable = true
//                                        versionAvailable = version
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            return (upgradeAvailable,versionAvailable)
//        }
    //MARK:- open app store
    func openAppStore() {
       // "https://itunes.apple.com/us/app/itunes-connect/id376771144"
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id376771144"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReceiveDataBackground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReceiveDataForeground"), object: nil)
    }
    @IBAction func cancelRideBTNN(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelRideVCPopupID") as! CancelRideVCPopup
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func mOnOffToggalBTN(_ sender: Any) {
//        if mOnoffToggalBTN.currentTitle == "offline"{
//            self.updateStatus(updateStatus: "1")
//        }else{
//            self.updateStatus(updateStatus: "3")
//        }
    }
    @IBAction func TechnicalIssueBTN(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TechnicalViewControllerPopUPID") as! TechnicalViewControllerPopUP
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func mExpireVehicleBTN(_ sender: Any) {
   
        let vc = self.storyboard?.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
extension HomeViewController : TechnicalPopUPD{
    func technical() {
        self.updateStatus(updateStatus: "3")
        self.offline()
        getLastRideDataApi()
    }
}
extension HomeViewController : CancelRide{
    //MARK:- cancel ride
    func CancelRide() {
        self.confirmationView.isHidden = true
        DispatchQueue.main.async {
            print("FIRST")
            self.getProfileDataApi()
        }
        DispatchQueue.main.async {
            print("SECOND")
         self.getSelectServicesApi()
        }
        DispatchQueue.main.async {
            print("THIRD")
            self.pendingRequestApi()
        }
    }
}
//MARK:- User Defined Func
extension HomeViewController {
    //MARK:- add current location marker
    func addCurrentLocationMarker() {
        let puppyGif = UIImage(named: "car")
        let imageView = UIImageView(image: puppyGif)
        imageView.frame = CGRect(x: 0, y: 0, width: 45, height: 30)
        if let location = locationManager.location {
            marker = GMSMarker(position: location.coordinate)
            marker.iconView = imageView
            marker.map = mapView
            marker.rotation = locationManager.location?.course ?? 0
        }
    }
    func setNavButton(){
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "green")
        if NSUSERDEFAULT.value(forKey: kUpdateDriveStatus) as? String  == "1"{
            my_switch.isOn = true
            my_switch.onTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            onOffValue = "Online"
        }
        else{
            my_switch.isOn = false
            my_switch.onTintColor = UIColor.clear
            onOffValue = "Offline"
        }
    }
    @IBAction func sideMenuButton(){
        let presentedVC = self.storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController")
        let nvc = UINavigationController(rootViewController: presentedVC)
        present(nvc, animated: false, pushing: true, completion: nil)
    }
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        let manager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch manager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    hasPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    hasPermission = true
                @unknown default:
                    break
                }
            } else {
            }
        } else {
            hasPermission = false
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return hasPermission
    }
}
extension HomeViewController : gobackHome {
    func gobackHomeVC(flag: Bool) {
        if flag == true{
            self.pendingRequestApi()
        }
    }
}
extension UIProgressView {
    @available(iOS 10.0, *)
    func setAnimatedProgress(progress: Float = 1, duration: Float = 1, completion: (() -> ())? = nil) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                let current = self.progress
                self.setProgress(current+(1/duration), animated: true)
            }
            if self.progress >= progress {
                timer.invalidate()
                if completion != nil {
                    completion!()
                }
            }
        }
    }
}
