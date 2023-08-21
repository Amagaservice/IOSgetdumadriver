//
//  HomeAPI.swift
//  OcoryDriver
//
//  Created by nile on 05/07/21.
//

import UIKit
import CoreLocation
import Alamofire

extension HomeViewController {
    //MARK:- mark payment recived api
    func markReceivedApi(rideId : String,updateDriverStatus :String){
        let param = ["ride_id":rideId,"driver_status": updateDriverStatus]
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "payment_as_recieved", params: param,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            print("Updating Driver Online Status Data Api  \(value)")
            let msg = (value["message"] as? String ?? "")
            if ((value["status"] as? Int ?? 0) == 1){
                self.showToast(message: "Payment received in cash")
                self.paymentView.isHidden = true
            }else{
                self.showAlert("GetDuma Driver", message: msg)
            }
        }
    }
    //MARK:-  get earning
    func getearning() {
        Indicator.shared.showProgressView(self.view)
        let year = Calendar.current.component(.year, from: Date())
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "earn?year=\(year)",authRequired: true) { (value) in
            print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                let amount = value["current_day_earning"] as? String
                var totalAmount  = " " + String(amount ?? "0" )
                self.mTotalEarning.setTitle(totalAmount as! String, for: .normal)
            }
        }
    }
    //MARK:-  update status
    func updateStatus(updateStatus : String){
        let param = ["is_online":updateStatus]
        DispatchQueue.main.async {
            NavigationManager.pushToLoginVC(from: self)
        }
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "update_driver_status", params: param,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            print("Updating Driver Status Data Api  \(value)")
            let msg = (value["message"] as? String ?? "")
            if ((value["status"] as? Int ?? 0) == 1){
             //   self.mOnoffToggalBTN.setTitle("online", for: .normal)
                if updateStatus == "1"{
                    if self.selectServicesStatus == .isSelected
                    {
                        self.getSelectServicesApi()
                        self.ServicesView.isHidden = false
                        NSUSERDEFAULT.set("yes", forKey: checknotifi)
                    }else{
                        self.arrSelectedRowsStatus.removeAll()
                        self.servicesList.reloadData()
                        self.ServicesView.isHidden = true
                    }
                    NSUSERDEFAULT.set(("online"), forKey: KOnOffStatus)
                    
                }else if updateStatus == "3"{
                    NSUSERDEFAULT.set(("offline"), forKey: KOnOffStatus)
                }
                if self.Doc_Pend != "yes"{
                    self.mDocumentPendingView.isHidden = true
                }
                self.toggalBTN = ""
                self.updateDriverLocation(lat: kCurrentLocaLat, long: kCurrentLocaLong)
               // self.updateDriverLocation(lat: "44.4942892", long: "-73.19008699999999")
                if self.selectServicesStatus == .isSelected {
                    self.showToast(message: "Driver Status Updated")
                }
                let total_working_hour = (value["total_working_hour"] as? Int ?? 0)
                self.settime(secTime: total_working_hour)
            }else{
                let total_working_hour = (value["total_working_hour"] as? Int ?? 0)
                self.settime(secTime: total_working_hour)
                
                self.toggalBTN = msg
                if self.Doc_Pend != "yes"{
                    self.mDocumentPendingView.isHidden = false
                }
                
               // NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
                self.offline()
                self.showAlert("GetDuma Driver", message: msg)
            }
        }
    }
    //MARK:-  set timer in side menu
    func settime(secTime:Int){
        if  secTime > 43200{
            print("12 hour done")
            NSUSERDEFAULT.set((43200), forKey: Ktimer)
            if my_switch.isOn == true{
                self.updateStatus(updateStatus: "3")
            }
        }else{
            NSUSERDEFAULT.set((secTime), forKey: Ktimer)
        }
//        if secTime > 61200{
//            logoutt()
//        }
       
    }
    
//     func checkdevicetokenAPI(){
//        self.conn.startConnectionWithPostType(getUrlString: "checkdevicetoken", params: ["":""], authRequired: true) { (value) in
//            Indicator.shared.hideProgressView()
//            if self.conn.responseCode == 1{
//                print(value)
//               // let device_type = (value["device_type"] as? String ?? "")
//                let device_token = (value["device_token"] as? String ?? "")
//                let deviceID =  UIDevice.current.identifierForVendor?.uuidString
//                if device_token != deviceID{
//                    NavigationManager.pushToLoginVC(from: self)
//                }
//            }
//        }
//    }
    
    //MARK:- get approval document status
    func getdocumentaApi() {
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "get_approval_document_status",authRequired: true) { (value) in
            print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                if ((value["data"] as? [String:Any]) != nil){
                    var model = [String:Any]()
                    model = value["data"] as! [String : Any]
                    if model["car_registration_approve_status"] as? String == "1" {
                        self.arr[0] = "Approved"
                    }
                    if model["license_approve_status"] as? String == "1"{
                        self.arr[1] = "Approved"
                    }
                    if model["insurance_approve_status"] as? String == "1" {
                        self.arr[2] = "Approved"
                    }
                    if model["inspection_approval_status"] as? String == "1" {
                        self.arr[5] = "Approved"
                    }
                    if model["car_expiry"] as? Bool == true{
                        self.arr[0] = "Expired"
                    }
                    if model["license_expiry"] as? Bool == true{
                        self.arr[1] = "Expired"
                    }
                    if model["insurance_expiry"] as? Bool == true{
                        self.arr[2] = "Expired"
                    }
                    if model["identification_expiry"] as? Bool == true{
                        self.arr[3] = "Expired"
                    }else{
                        self.arr[3] = "Approved"
                    }
                    if model["inspection_expiry"] as? Bool == true{
                        self.arr[4] = "Expired"
                    }
                }
                if value["background_approval_status"] as? String == "1" {
                    self.arr[4] = "Approved"
                }
              //  self.mTableV.reloadData()
                if self.arr.contains("Pending"){
                    self.Doc_Pend = "yes"
                    self.mDocumentPendingView.isHidden = false
                    self.updateStatus(updateStatus: "3")
                    self.offline()
                }else{
                    self.Doc_Pend = ""
                    self.mDocumentPendingView.isHidden = true
                }
                if self.arr.contains("Expired"){
                    self.Doc_Exp = "yes"
                    self.updateStatus(updateStatus: "3")
                    self.offline()
                    self.mactionRLBL.text = "Upload required docs to go online."
                    self.mExpireVehicle.isHidden = false
                }else{
                    self.Doc_Exp = ""
                    self.mExpireVehicle.isHidden = true
                }
                
                
            }
        }
    }
    //MARK:-  make driver offline
    func offline(){
        print("Offline")
        // sender.backgroundColor = UIColor.red
        NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
        offlineOnlineLabel.text = "Offline"
        onOffStatus = onOff.offline
        my_switch.onTintColor = UIColor.clear
        offlineOnlineBtn.setTitle("Offline", for: .normal)
        offlineOnlineBtn.backgroundColor = UIColor.red
        my_switch.isOn = false
        selectServicesStatus = .isNotSelected
        // self.updateStatus(updateStatus: "3")
        UIApplication.shared.isIdleTimerDisabled = false
    }
//    {
//        print( "The switch is now false!" )
//        NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
//        offlineOnlineLabel.text = "Offline"
//        onOffStatus = onOff.offline
//        my_switch.onTintColor = UIColor.clear
//        offlineOnlineBtn.setTitle("Offline", for: .normal)
//        offlineOnlineBtn.backgroundColor = UIColor.red
//        selectServicesStatus = .isNotSelected
//        self.updateStatus(updateStatus: "3")
//        UIApplication.shared.isIdleTimerDisabled = false
//    }
    
//    func timeGapBetweenDates(previousDate : String,currentDate1 : String)
//    {
//        if previousDate != "" && currentDate1 != ""{
//            let dateString1 = previousDate
//            let dateString2 = currentDate1
//            let Dateformatter = DateFormatter()
//            Dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let date1 = Dateformatter.date(from: dateString1)
//            let date2 = Dateformatter.date(from: dateString2)
//            let distanceBetweenDates: TimeInterval? = date2?.timeIntervalSince(date1!)
//            let secBetweenDates = Int((distanceBetweenDates! / 1))
//            if  secBetweenDates > 43200{
//                print("12 hour done")
//                if my_switch.isOn == true{
//                    self.updateStatus(updateStatus: "3")
//                }
//            }
//            if secBetweenDates > 61200{
//              //  logoutt()
//            }
//            NSUSERDEFAULT.set((secBetweenDates), forKey: Ktimer)
//        }
//
//    }
    //MARK:-  logout api
    func logoutt(){
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "logout", params: [String : String](), authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                NavigationManager.pushToLoginVC(from: self)
            }
        }
    }
//    //MARK:- offline user
//    func logO(){
//        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
//        if let appDomain = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: appDomain)
//        }
//        UserDefaults.standard.synchronize()
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
//        UserDefaults.standard.synchronize()
//        NavigationManager.pushToLoginVC(from: self)
////
//    }
    //MARK:-  accept reject ride api
    func acceptRejectStatus(confirmStatus : String , acceptRejectView : acceptReject){
        print("ACCEPT REJECT API")
        let param = [ "ride_id" : kRideId ,"status" : kConfirmationStatus]
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "accept_ride", params: param,authRequired: true) { (value) in
            
            print(value)
            let msg = (value["message"] as? String ?? "")
            Indicator.shared.hideProgressView()
            if ((value["status"] as? Int ?? 0) == 1){
                self.getLastRideDataApi()
                //  self.showAlert("Ocory", message: msg)
                //  kNotificationAction = ""
                if kConfirmationStatus == "CANCELLED"{
                    self.confirmationView.isHidden = true
                    self.showToast(message: msg)
                }
                else if kConfirmationStatus == "START_RIDE"{
                   // self.offlineOnlineBtn.isUserInteractionEnabled = false
                 //   self.my_switch.isUserInteractionEnabled = false
                }
                else if kConfirmationStatus == "COMPLETED"{
                 //   self.offlineOnlineBtn.isUserInteractionEnabled = false
                 //   self.my_switch.isUserInteractionEnabled = false
                    self.confirmationView.isHidden = true
                //    self.updateStatus(updateStatus: "3")
                    self.showToast(message: msg)
                    self.getLastRideDataApi()
                }
                else{
                    self.confirmationView.isHidden = false
                    self.showToast(message: msg)
                }
            }else{
                self.acceptRejectStatus(confirmStatus : confirmStatus , acceptRejectView : acceptRejectView)
               // self.showAlert("GetDuma Driver", message: msg)
            }
        }
    }
    //MARK:- cancel ride api
    func cancelRideStatus(rideId : String){
        print("CANCEL RIDE API")
        kRequestStatus = ""
        let param = [ "ride_id" : rideId ,"status" : "CANCELLED"]
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "accept_ride", params: param,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            print(value)
            let msg = (value["message"] as? String ?? "")
            if ((value["status"] as? Int ?? 0) == 1){
                //  self.showAlert("Ocory", message: msg)
                kNotificationAction = ""
                kConfirmationAction = ""
                kRequestStatus = ""
                kRideId = ""
                self.confirmationView.isHidden = true
                self.servicesList.reloadData()
                self.getLastRideDataApi()
                self.showToast(message: msg)
            }else{
                self.showAlert("GetDuma Driver", message: msg)
            }
            
        }
        
    }
    //MARK:-  get ride status
//    func getRideStatus(ride_id : String){
//        let param = ["ride_id": ride_id]
//        print(param)
//        Indicator.shared.showProgressView(self.view)
//        self.conn.startConnectionWithPostType(getUrlString: "get_ride_status", params: param,authRequired: true) { (value) in
//            print("getRideStatus data \(value)")
//            Indicator.shared.hideProgressView()
//            if self.conn.responseCode == 1{
//                // print(value)
//                let msg = (value["message"] as? String ?? "")
//                if ((value["status"] as? Int ?? 0) == 1){
//                    if let body = (value as? [String:Any])?["data"] as? [String:Any] {
//                        do {
//                            let jsondata = try JSONSerialization.data(withJSONObject: body , options: .prettyPrinted)
//                            let encodedJson = try JSONDecoder().decode(userCustomerModal.self, from: jsondata)
//                            self.customerData = encodedJson
//                            self.confirmationView.isHidden = false
//                            kPickAddress = self.customerData?.pickup_adress  ?? ""
//                            kDropAddress = self.customerData?.drop_address  ?? ""
//                            let pickLat = self.customerData?.pickup_lat  ?? ""
//                            let pickLong = self.customerData?.pickup_long  ?? ""
//                            
//                            let dropLat = self.customerData?.drop_lat  ?? ""
//                            let dropLong = self.customerData?.drop_long  ?? ""
//                            kDestinationLatLong = "\(dropLat)" + "," + "\(dropLong)"
//                            kCustomerMobile = self.customerData?.mobile  ?? ""
//                            kDistanceInMiles = self.customerData?.distance  ?? ""
//                            kRidername = self.customerData?.user_name  ?? ""
//                            kRideId = self.customerData?.ride_id  ?? ""
//
//                            self.totalFareLbl.text =    "$ " + "\(self.customerData?.amount ?? "")"
//                            let firsLocation = CLLocation(latitude:pickLat.toDouble() ?? 0.0, longitude:pickLong.toDouble() ?? 0.0)
//                            let secondLocation = CLLocation(latitude: dropLat.toDouble() ?? 0.0, longitude: dropLong.toDouble() ?? 0.0)
//                            // let distance = firsLocation.distance(from: secondLocation) / 1000
//                            let distance = firsLocation.distance(from: secondLocation) * 0.000621371
//                            print(distance)
//                            let roundedValue = round(distance * 10) / 10.0
//                            print(roundedValue)
//                            self.totalDistanceLbl.text = "\(roundedValue)" + " Miles"
//                            self.mUserNAme.text = "Rider: " + kRidername
//                            self.fromAddressLbl.text = self.customerData?.pickup_adress  ?? ""
//                            self.toAddressLbl.text = self.customerData?.drop_address  ?? ""
//                            
//                            kConfirmationAction =  self.customerData?.ride_status  ?? ""
//                            print(kConfirmationAction)
//                            if kNotificationAction == "START_RIDE" || kConfirmationAction == "START_RIDE"{
//                                self.confirmationView.isHidden = false
//                                self.startRideView.isHidden = true
//                                self.accptRejectView.isHidden = true
//                                self.recordView.isHidden = false
//                                self.navigatetoD()
//                            }
//                            else if kNotificationAction == "ACCEPTED" || kConfirmationAction ==  "ACCEPTED"{
//                                self.tracking()
//                                self.accptRejectView.isHidden = true
//                                self.startRideView.isHidden = false
//                                self.recordView.isHidden = true
//                            }
//                            else if kNotificationAction == "CANCELLED" || kConfirmationAction  ==  "CANCELLED"{
//                                self.startRideView.isHidden = true
//                                self.accptRejectView.isHidden = true
//                                self.confirmationView.isHidden = true
//                                self.recordView.isHidden = true
//                            }
//                            else if kNotificationAction == "COMPLETED" || kConfirmationAction  == "COMPLETED"{
//                                self.confirmationView.isHidden = true
//                                kNotificationAction = ""
//                                kConfirmationAction = ""
//                                kRideId = ""
//                            }
//                            else {
//                                print("hmm")
//                            }
//                            
//                        }catch {
//                            print(false, error.localizedDescription)
//                        }
//                    }
//                }else{
//                    self.showAlert("GetDuma Driver", message: msg)
//                }
//            }
//        }
//    }
    //MARK:-  update driver lat long
    func updateDriverLocation(lat : String,long : String){
        if lat == "" && long == ""{
            //  self.showAlert("Location Permission Required", message: "Please enable location permissions in settings.")
        }
        else{
            let param = ["lat": lat , "long" : long]
            print(param)
            Indicator.shared.showProgressView(self.view)
            self.conn.startConnectionWithPostType(getUrlString: "update_lat_long", params: param,authRequired: true) { (value) in
                Indicator.shared.hideProgressView()
                print(value)
                let msg = (value["message"] as? String ?? "")
                DispatchQueue.main.async {
                    if self.conn.responseCode == 1{
                        // print(value)
                        if ((value["status"] as? Int ?? 0) == 1){
                            if let body = (value as? [String:Any])?["data"] as? [String:Any] {
                                
                            }
                        }else{
                            self.showToast(message: msg)
                        }
                    }
                    else{
                        guard let stat = value["Error"] as? String, stat == "ok" else {
                            // self.showAlert("Ocory", message: "\(String(describing: stat))")
                            return
                        }
                    }
                }
            }
        }
        
    }
    //MARK:-  change ride status
    
    func changeRideStatus(rideId : String,status : String){
        let param = ["ride_id": rideId , "status" : status]
        print(param)
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "change_ride_status", params: param,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            print(value)
            let msg = (value["message"] as? String ?? "")
            if self.conn.responseCode == 1{
                // print(value)
                if ((value["status"] as? Int ?? 0) == 1){
                    if let body = (value as? [String:Any])?["data"] as? [String:Any] {

                    }
                }
                else{
                    self.showToast(message: msg)
                }
            }
        }
    }
    //MARK:- pending ride api
    
    func pendingRequestApi(){
        Indicator.shared.showProgressView(self.view)
        let url = "api/user/rides?status=PENDING"
        //    https://www.niletechinnovations.com/projects/ocory/rides?status=PENDING
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: url,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            let msg = (value["message"] as? String ?? "")
            if self.conn.responseCode == 1{
                if (value["status"] as? Int ?? 0) == 1{
                    let data = (value["data"] as? [[String:AnyObject]] ?? [[:]])
                    
                    if data.count == 0{
                        self.pendingLastRideStatus = true
                        self.getLastRideDataApi()
                    }
                    else{
                        print("Pending API Data=== \(value)")
                        for items in data {
                            if  let dataId = items["ride_id"] as? String{
                                self.pendingRideId = dataId
                                kRideId = dataId
//                                self.confirmationView.isHidden = false
//                                self.accptRejectView.isHidden = false
                                let data = (value["data"] as? [[String:AnyObject]] ?? [[:]])
                                do{
                                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                    self.pendingReqData = try newJSONDecoder().decode(rides.self, from: jsonData)
                                    kRideId = self.pendingReqData.first?.rideID  ?? ""
                                 //   self.confirmationView.isHidden = false
                                    kPickAddress = self.pendingReqData.first?.pickupAdress  ?? ""
                                    kDropAddress = self.pendingReqData.first?.dropAddress  ?? ""
                                    let pickLat = self.pendingReqData.first?.pickupLat  ?? ""
                                    let pickLong = self.pendingReqData.first?.pickupLong  ?? ""
                                    
                                    let dropLat = self.pendingReqData.first?.dropLat  ?? ""
                                    let dropLong = self.pendingReqData.first?.dropLong  ?? ""
                                    kDestinationLatLong = "\(dropLat)" + "," + "\(dropLong)"
                                    kDistanceInMiles = self.pendingReqData.first?.distance  ?? ""
                                    
                                    self.totalFareLbl.text =    "$ " + "\(self.pendingReqData.first?.amount ?? "")"
                                    self.totalDistanceLbl.text =   "\(self.pendingReqData.first?.distance  ?? "" )" + " " + "Miles"
                                    self.mUserNAme.text = "Rider: " + kRidername
                                    self.fromAddressLbl.text = self.pendingReqData.first?.pickupAdress  ?? ""
                                    self.toAddressLbl.text = self.pendingReqData.first?.dropAddress  ?? ""
                                    kRequestStatus = self.pendingReqData.first?.status  ?? ""
                                    if kNotificationAction == "START_RIDE" || kConfirmationAction == "START_RIDE"{
                                        self.confirmationView.isHidden = false
                                        self.startRideView.isHidden = true
                                        self.accptRejectView.isHidden = true
                                        self.recordView.isHidden = false
                                        self.offlineOnlineBtn.isUserInteractionEnabled = false
                                        self.navigatetoD()
                                            //self.my_switch.isUserInteractionEnabled = false
                                    }
                                    else if kNotificationAction == "ACCEPTED" || kConfirmationAction ==  "ACCEPTED"{
                                        self.tracking()
                                        self.getnumber()
                                        self.accptRejectView.isHidden = true
                                        self.startRideView.isHidden = false
                                        self.recordView.isHidden = true
                                    }
                                    else if kNotificationAction == "COMPLETED" || kConfirmationAction  == "COMPLETED"{
                                        let pendingPaymentStatusData = self.pendingReqData.first?.paymentStatus  ?? ""
                                        
                                        if  pendingPaymentStatusData ==  "COMPLETED"{
                                            self.startRideView.isHidden = true
                                            self.accptRejectView.isHidden = true
                                            self.confirmationView.isHidden = true
                                            self.recordView.isHidden = true
                                            kNotificationAction = ""
                                            kConfirmationAction = ""
                                            kRideId = ""
                                            self.paymentView.isHidden = true
                                            self.amountLblFinal.text =   "$" + " " + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is Received"
                                            self.ServicesView.isHidden = true
                                        }
                                        else{
                                            kNotificationAction = ""
                                            kConfirmationAction = ""
                                            self.confirmationView.isHidden = true
                                            self.paymentView.isHidden = false
                                            self.offlineOnlineBtn.isUserInteractionEnabled = false
                                          //  self.my_switch.isUserInteractionEnabled = false
                                            self.amountLblFinal.text =   "$" + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is Pending"
                                            self.ServicesView.isHidden = true

                                        }
                                    }
                                    else if kNotificationAction == "FAILED" || kConfirmationAction  == "FAILED"{
                                        self.confirmationView.isHidden = true
                                        kNotificationAction = ""
                                        kConfirmationAction = ""
                                        kRideId = ""
                                    }
                                    else if kNotificationAction == "PENDING" || kConfirmationAction  == "PENDING" || kRequestStatus == "PENDING"{
                                        if   self.appMovedToForegroundStatus == true {
                                            if self.offlineOnlineLabel.text == "Online"{
                                                print("appMovedToForegroundTrue")
                                                self.confirmationView.isHidden = false
                                                self.accptRejectView.isHidden = false
                                                self.startRideView.isHidden = true
                                                self.recordView.isHidden = true
                                                self.appMovedToForegroundStatus = false
                                                
                                                self.startProgressAndAPIRequest()
//                                                self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.startTimer(_:)), userInfo: nil, repeats: true)
//                                                self.progressView.setAnimatedProgress(duration: 20) {
//                                                    print("Done!")
//                                                }
                                            }else{
                                                self.startRideView.isHidden = true
                                                self.accptRejectView.isHidden = true
                                                self.confirmationView.isHidden = true
                                                self.recordView.isHidden = true
                                                kNotificationAction = ""
                                                kConfirmationAction = ""
                                                kRideId = ""
                                                self.paymentView.isHidden = true
                                            }
                                        }
                                    }
                                    else if kNotificationAction == "NOT_CONFIRMED" || kConfirmationAction  == "NOT_CONFIRMED" || kRequestStatus == "NOT_CONFIRMED"{
                                        if self.offlineOnlineLabel.text == "Online"{
                                            self.confirmationView.isHidden = false
                                            self.accptRejectView.isHidden = false
                                            self.startRideView.isHidden = true
                                            self.recordView.isHidden = true
                                            
                                            self.startProgressAndAPIRequest()
//                                            self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.startTimer(_:)), userInfo: nil, repeats: true)
//                                            self.progressView.setAnimatedProgress(duration: 20) {
//                                                print("Done!")
                                                //  self.cancelledUsingProgressBarTime()
                                      //      }
                                        }else{
                                            self.startRideView.isHidden = true
                                            self.accptRejectView.isHidden = true
                                            self.confirmationView.isHidden = true
                                            self.recordView.isHidden = true
                                            kNotificationAction = ""
                                            kConfirmationAction = ""
                                            kRideId = ""
                                            self.paymentView.isHidden = true
                                        }
                                        
                                    }
                                    
                                    else if kNotificationAction == "CANCELLED" || kConfirmationAction  ==  "CANCELLED"{
                                        self.startRideView.isHidden = true
                                        self.accptRejectView.isHidden = true
                                        self.confirmationView.isHidden = true
                                        self.recordView.isHidden = true
                                    }
                                      else {
                                        print("hmm")
                                        self.confirmationView.isHidden = true
                                        self.accptRejectView.isHidden = true
                                        self.startRideView.isHidden = true
                                        self.recordView.isHidden = true
                                    }
                                }catch{
                                    print(error.localizedDescription)
                                }
                                // self.getRideStatus(ride_id:dataId)
                            }
                        }
                    }
                }
            }
            else{
                print("No Ride Available")
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //  self.showToast(message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
}
extension HomeViewController{
    //MARK:-  get profile data api
    func getProfileDataApi() {
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "get_profile",authRequired: true) { (value) in
            // print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print("Getting Profile Data Api  \(value)")
                let msg = (value["message"] as? String ?? "")
                if (value["status"] as? Int ?? 0) == 1{
                    let data = (value["data"] as? [String:AnyObject] ?? [:])
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        self.profileDetails = try newJSONDecoder().decode(ProfileData.self, from: jsonData)
                        
                        let country_code = self.profileDetails?.country_code ?? ""
                        let mobile = self.profileDetails?.mobile ?? ""
                       // var mobileno = country_code + mobile
                        NSUSERDEFAULT.set(country_code, forKey: kownCcode)
                        NSUSERDEFAULT.set(mobile, forKey: kownMobile)
                        NSUSERDEFAULT.set((self.profileDetails?.name ?? ""), forKey: kName)
                        NSUSERDEFAULT.set((self.profileDetails?.email ?? ""), forKey: kEmail)
                        NSUSERDEFAULT.set((self.profileDetails?.profile_pic ?? ""), forKey: kProfilePic)
                        self.servicesList.reloadData()
                    }catch{
                        print(error.localizedDescription)
                    }
                }
                else{
                    guard let stat = value["Error"] as? String, stat == "ok" else {
                        // self.showToast(message: "\(String(describing: stat))")
                        return
                    }
                }
            }
        }
    }
    //MARK:- get added vehicle services
    func getSelectServicesApi() {
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "get_added_vehicle_services",authRequired: true) { (value) in
            // print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print("Getting Select Services Data Api  \(value)")
                let msg = (value["message"] as? String ?? "")
                if (value["status"] as? Int ?? 0) == 1{
                    let data = (value["data"] as? [[String:AnyObject]] ?? [[:]])
                    do{
                        self.arrSelectedRowsNew.removeAll()
                        self.arrnotSelectedRowsNew.removeAll()
                        self.servicesData.removeAll()
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        self.servicesData = try newJSONDecoder().decode(selectServicesModal.self, from: jsonData)
                        self.servicesList.reloadData()
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            else{
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //  self.showToast(message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
    
    //MARK:- add selected serive api
    func addSelectedServicesApi(){
        
        var stringData = arrSelectedRowsNew[0]
        let param = ["service_id": stringData, "status" : "1" ] as [String : Any]
        print(param)
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "add_service", params: param ,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                NSUSERDEFAULT.set("no", forKey: checknotifi)
                let msg = (value["message"] as? String ?? "")
                if ((value["status"] as? Int ?? 0) == 1){
                    if self.arrSelectedRowsNew.count == 2{
                      //  self.removeSelectedServicesApi2.removeAll()
                        self.addSelectedServicesApi2()
                    }else{
                        if self.arrnotSelectedRowsNew.count != 0{
                            self.removeSelectedServicesApi2()
                        }else{
                            self.getSelectServicesApi()
                            self.ServicesView.isHidden = true
                        }
                    }
                }else{
                    self.showAlert("GetDuma Driver", message: msg)
                }
            }
            else{
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //  self.showAlert("Ocory", message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
    //MARK:- add more service
    func addSelectedServicesApi2(){
        var stringData = arrSelectedRowsNew[1]
        let param = ["service_id": stringData, "status" : "1" ] as [String : Any]
        print(param)
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "add_service", params: param ,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                let msg = (value["message"] as? String ?? "")
                if ((value["status"] as? Int ?? 0) == 1){
                    if self.arrnotSelectedRowsNew.count != 0{
                        self.removeSelectedServicesApi2()
                    }else{
                        
                        self.getSelectServicesApi()
                        self.ServicesView.isHidden = true
                    }
                   
                }else{
                    self.showAlert("GetDuma Driver", message: msg)
                }
            }
            else{
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //  self.showAlert("Ocory", message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
    //MARK:- add more service
    func removeSelectedServicesApi2(){
        var stringData = arrnotSelectedRowsNew[0]
        let param = ["service_id": stringData, "status" : "0" ] as [String : Any]
        print(param)
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "add_service", params: param ,authRequired: true) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                let msg = (value["message"] as? String ?? "")
                if ((value["status"] as? Int ?? 0) == 1){
                    self.getSelectServicesApi()
                    self.ServicesView.isHidden = true
                }else{
                    self.showAlert("GetDuma Driver", message: msg)
                }
            }
            else{
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //  self.showAlert("Ocory", message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
    //MARK:- get last ride api 
    func getLastRideDataApi(){
     //   Indicator.shared.showProgressView(self.view)
        DispatchQueue.main.async {
            NavigationManager.pushToLoginVC(from: self)
        }
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "get_last_ride",authRequired: true) { (value) in
            print("Last Ride Data Api  \(value)")
         //   Indicator.shared.hideProgressView()
            let msg = (value["message"] as? String ?? "")
            if self.conn.responseCode == 1{
                if (value["status"] as? Int ?? 0) == 1{
                    let change_vehicle = (value["change_vehicle"] as? Int ?? 0)
                    if value["change_vehicle"] as? Bool == true{
                        self.change_vehicle = "yes"
                        self.updateStatus(updateStatus: "3")
                        self.offline()
                        self.mactionRLBL.text = "Your current vehicle has been exipre.\nPlease add new vehicle"
                        self.mExpireVehicle.isHidden = false
                      //  self.showAlert("Getdume", message: "Your vehicle is exipre.\nPlease change your vehicle")
                    }
  //                  let user_status = (value["user_status"] as? Bool)
//                    if user_status == true {
//                        self.showAlert("Getdume", message: "Your profile is exipre.\nPlease change your profile pic")
//                    }
                    let data = (value["data"] as? [String:AnyObject] ?? [:])
                    do {
                        let jsondata = try JSONSerialization.data(withJSONObject: data , options: .prettyPrinted)
                        let encodedJson = try JSONDecoder().decode(lastRideModalData.self, from: jsondata)
                        self.lastRideData = encodedJson
                        kRideId = self.lastRideData?.ride_id  ?? ""
                        self.confirmationView.isHidden = false
                        kPickAddress = self.lastRideData?.pickup_adress  ?? ""
                        kDropAddress = self.lastRideData?.drop_address  ?? ""
                        let pickLat = self.lastRideData?.pickup_lat  ?? ""
                        let pickLong = self.lastRideData?.pickup_long  ?? ""
                        let dropLat = self.lastRideData?.drop_lat  ?? ""
                        let dropLong = self.lastRideData?.drop_long  ?? ""
                        kDestinationLatLong = "\(dropLat)" + "," + "\(dropLong)"
                        kCustomerMobile = self.lastRideData?.mobile  ?? ""
                        kDistanceInMiles = self.lastRideData?.distance  ?? ""
                        kRidername = self.lastRideData?.user_name  ?? ""
                        self.totalFareLbl.text =    "$ " + "\(self.lastRideData?.amount ?? "")"
                        self.fromAddressLbl.text = self.lastRideData?.pickup_adress  ?? ""
                        self.toAddressLbl.text = self.lastRideData?.drop_address  ?? ""
                        
                        self.totalDistanceLbl.text =   "\(self.lastRideData?.distance  ?? "" )" + " " + "Miles"
                        self.mUserNAme.text = "Rider: " + kRidername
                  //      kRideId = self.customerData?.ride_id  ?? ""

                        self.fromAddressLbl.text = self.lastRideData?.pickup_adress  ?? ""
                        self.toAddressLbl.text = self.lastRideData?.drop_address  ?? ""
                        kConfirmationAction =  self.lastRideData?.status  ?? ""
                        
                        print("last ride status --- \(kConfirmationAction)" )
                        let feedbackStatus = self.lastRideData?.feedback ?? ""
                        print(kConfirmationAction)
                        let paymentStatusData = self.lastRideData?.payment_status ?? ""
                        if kNotificationAction == "START_RIDE" || kConfirmationAction == "START_RIDE"{
                            self.confirmationView.isHidden = false
                            self.startRideView.isHidden = true
                            self.accptRejectView.isHidden = true
                            self.recordView.isHidden = false
                            self.offlineOnlineBtn.isUserInteractionEnabled = false
                            self.navigatetoD()
                         //   self.my_switch.isUserInteractionEnabled = false
                        }else if kNotificationAction == "ACCEPTED" || kConfirmationAction ==  "ACCEPTED"{
                            self.confirmationView.isHidden = false
                            self.accptRejectView.isHidden = true
                            self.startRideView.isHidden = false
                            self.recordView.isHidden = true
                            self.tracking()
                            self.getnumber()
                        }
                        else if kNotificationAction == "CANCELLED" || kConfirmationAction  ==  "CANCELLED"{
                            self.startRideView.isHidden = true
                            self.accptRejectView.isHidden = true
                            self.confirmationView.isHidden = true
                            self.recordView.isHidden = true
                        }
                        else if kNotificationAction == "COMPLETED" || kConfirmationAction  == "COMPLETED"{
                            if  paymentStatusData ==  "COMPLETED"{
                                self.startRideView.isHidden = true
                                self.accptRejectView.isHidden = true
                                self.confirmationView.isHidden = true
                                self.recordView.isHidden = true
                                kNotificationAction = ""
                                kConfirmationAction = ""
                                kRideId = ""
                                self.paymentView.isHidden = true
                                self.amountLblFinal.text =   "$" + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is Received"
                                self.ServicesView.isHidden = true
                            }
                            else{
                                kNotificationAction = ""
                                kConfirmationAction = ""
                                self.confirmationView.isHidden = true
                                self.paymentView.isHidden = false
                                self.offlineOnlineBtn.isUserInteractionEnabled = false
                               // self.my_switch.isUserInteractionEnabled = false
                                self.amountLblFinal.text =   "$" + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is Pending"
                                self.ServicesView.isHidden = true
                            }
                        }
                        else if kNotificationAction == "FAILED" || kConfirmationAction  == "FAILED"{
                            self.confirmationView.isHidden = true
                            kNotificationAction = ""
                            kConfirmationAction = ""
                            kRideId = ""
                        }
                        else if kNotificationAction == "PENDING" || kConfirmationAction  == "PENDING"{
                            
//                            if self.pendingLastRideStatus == true {
//                                self.confirmationView.isHidden = true
//                                self.accptRejectView.isHidden = true
//                                self.startRideView.isHidden = true
//                                self.recordView.isHidden = true
//                            }else{
                                if self.offlineOnlineLabel.text == "Online"{
                                    self.confirmationView.isHidden = false
                                    self.accptRejectView.isHidden = false
                                    self.startRideView.isHidden = true
                                    self.recordView.isHidden = true
                                    self.startProgressAndAPIRequest()
//                                    self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.startTimer(_:)), userInfo: nil, repeats: true)
//                                    self.progressView.setAnimatedProgress(duration: 20) {
//                                        print("Done!")
                                        // self.cancelledUsingProgressBarTime()
                             //       }
                                }else{
                                    self.startRideView.isHidden = true
                                    self.accptRejectView.isHidden = true
                                    self.confirmationView.isHidden = true
                                    self.recordView.isHidden = true
                                    kNotificationAction = ""
                                    kConfirmationAction = ""
                                    kRideId = ""
                                    self.paymentView.isHidden = true
                                }

                    //        }
                        }else if kNotificationAction == "NOT_CONFIRMED" || kConfirmationAction  == "NOT_CONFIRMED"{
                            //   if self.pendingLastRideStatus == true {
                            if self.offlineOnlineLabel.text == "Online"{
                                self.confirmationView.isHidden = true
                                self.accptRejectView.isHidden = true
                                self.startRideView.isHidden = true
                                self.recordView.isHidden = true
                                self.startProgressAndAPIRequest()
//                                self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.startTimer(_:)), userInfo: nil, repeats: true)
//                                self.progressView.setAnimatedProgress(duration: 20) {
//                                    print("Done!")
                           //     }
                            }else{
                                self.startRideView.isHidden = true
                                self.accptRejectView.isHidden = true
                                self.confirmationView.isHidden = true
                                self.recordView.isHidden = true
                                kNotificationAction = ""
                                kConfirmationAction = ""
                                kRideId = ""
                                self.paymentView.isHidden = true
                            }
                        }
                        else {
                            print("hmm")
                            self.confirmationView.isHidden = true
                            self.accptRejectView.isHidden = true
                            self.startRideView.isHidden = true
                            self.recordView.isHidden = true
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
                else{
                    let errMsg = (value["Error"] as? String ?? "")
                    //        self.showAlert("Ocory", message: errMsg)
                }
            }
            else{
                guard let stat = value["Error"] as? String, stat == "ok" else {
                    //       self.showAlert("Ocory", message: "\(String(describing: stat))")
                    return
                }
            }
        }
    }
    
    //MARK:- accept ride api
    func getnumber(){
        let url = "api/user/rides?id=\(kRideId)&status=ACCEPTED"
      //  Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: url,authRequired: true) { (value) in
            print(value)
        //    Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                if (value["status"] as? Int ?? 0) == 1{
                    let data = (value["data"] as? [[String:AnyObject]] ?? [[:]])
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        var acceptedReqData = [RidesData]()
                        acceptedReqData = try newJSONDecoder().decode(rides.self, from: jsonData)
                        if acceptedReqData.count > 1{
                            kCustomerMobile = acceptedReqData[0].userMobile!
                        }

                     //   self.acceptedReq_tableView.reloadData()
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    func tracking(){
        if  self.trackYN != "no"{
            var refreshAlert = UIAlertController(title: "Track Ride Address", message: "Do you want to track rider's Address?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.trackYN = "no"
                self.trackBT()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.trackYN = "no"
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    func navigatetoD(){
        if  self.navYN != "no"{
            var refreshAlert = UIAlertController(title: "Navigate to destination", message: "Do you want navigation to rider's destination?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.navYN = "no"
                self.navigateBTN()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.navYN = "no"
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
}
extension Int {

    func getString(prefix: Int) -> String {
        return "\(prefix)\(self)"
    }

    func getString(prefix: String) -> String {
        return "\(prefix)\(self)"
    }
}
