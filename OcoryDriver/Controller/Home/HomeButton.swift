//
//  HomeRecording.swift
//  OcoryDriver
//
//  Created by nile on 10/09/21.
//

import UIKit
import Alamofire

extension HomeViewController {
    //MARK:- User Defined Func
    @IBAction func cancelServiceBtnAction(_ sender: Any) {
        ServicesView.isHidden = true
        self.arrSelectedRowsStatus.removeAll()
    }
    //MARK:- fun for register xib
    func registerCell(){
        let imgNib = UINib(nibName: "SelectServicesVC", bundle: nil)
        self.servicesList.register(imgNib, forCellReuseIdentifier: "SelectServicesVC")
        
        let btnNib = UINib(nibName: "SubmitServicesCell", bundle: nil)
        self.servicesList.register(btnNib, forCellReuseIdentifier: "SubmitServicesCell")
    }
    func startProgressAndAPIRequest() {
        progressView.progress = 0.0

               // Animate the progress to 1.0 over 20 seconds
               UIView.animate(withDuration: 20.0, animations: {
                   self.progressView.setProgress(1.0, animated: true)
               }) { (_) in
                   // Animation completed, start a timer to clear the progress view after 20 seconds
                   self.progressTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false, block: { (_) in
                       self.progressView.progress = 0.0
                       self.cancelProgressAnimation()
                       self.hitAPI()
                   })
               }
    }
    func cancelProgressAnimation() {
            progressTimer?.invalidate()
            progressView.progress = 0.0
        }
    func hitAPI() {
        // Perform your API request here
        // For demonstration purposes, we'll just print a message after the 20 seconds
        if kRequestStatus == "PENDING" ||  kNotificationAction == "PENDING" || kConfirmationAction == "PENDING" {
            if kConfirmationStatus == "ACCEPTED" || kConfirmationStatus == "START_RIDE" || kConfirmationStatus == "COMPLETED" || kConfirmationStatus == "CANCELLED" {
                print("")
            }else{
                self.cancelRideStatus(rideId: kRideId)
            }
        }
    }
    
    
    
    
//    @objc func startTimer(_ timer: Timer) {
//        print("Timer Start")
//        if kRequestStatus == "PENDING" ||  kNotificationAction == "PENDING" && kConfirmationAction == "PENDING" {
//            if kConfirmationStatus == "ACCEPTED" || kConfirmationStatus == "START_RIDE" || kConfirmationStatus == "COMPLETED"{
//               print("")
//            }else{
//                self.cancelRideStatus(rideId: kRideId)
//            }
//
//        }
//        self.timer?.invalidate()
//        self.timer = nil
//    }
    
    @objc func failedTimer(_ timer: Timer){
        print("Failded Timer Start")
        var timerCountStatus = false
        if kRideId != "" && timerCountStatus == true {
            print("work 3 minutes more")
            timerCountStatus = false
        }
        if kRideId != "" && timerCountStatus == false {
            print("work 3 minutes")
            timerCountStatus = true
            if  kNotificationAction == "PENDING" && kConfirmationAction == "PENDING" {
                self.cancelRideStatus(rideId: kRideId)
            }
        }
    }
    
//    @objc func cancelledUsingProgressBarTime(){
//        print("Failed cancelledUsingProgressBarTime")
//        var timerCountStatus = false
//        if kRideId != "" && timerCountStatus == true {
//            print("work 20 seconds more")
//            timerCountStatus = false
//        }
//        if kRideId != "" && timerCountStatus == false {
//            print("work 20 secondss")
//            timerCountStatus = true
//            if  kNotificationAction == "PENDING" || kConfirmationAction == "NOT_CONFIRMED" || kRequestStatus == "NOT_CONFIRMED" || kRequestStatus == "PENDING" {
//                progressView.progress = 0.0
//                self.cancelRideStatus(rideId: kRideId)
//            }
//        }
//    }
//    @objc func failedTimerPendingRequest(_ timer: Timer){
//        print("Failded Timer Pending Request")
//        if  kRideId != "" && kNotificationAction == "PENDING" || kConfirmationAction == "PENDING" {
//            self.cancelRideStatus(rideId: kRideId)
//        }
//    }
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        appMovedToForegroundStatus = true
        self.pendingRequestApi()
//        if kRideId != ""{
//            self.getRideStatus(ride_id:kRideId)
//        }
    }
    @objc func loadBackgroundList(_ notification: NSNotification){
        
        let notificationData = notification.userInfo
        if let dict = notificationData as? [String: Any] {
            print("userInfo: ", dict)
            if let dictData = dict["action"] as? String{
                print(dictData)
                kNotificationAction = dictData
                if kNotificationAction == "PENDING"{
                    self.pendingRequestApi()
                  //  timer = Timer.scheduledTimer(timeInterval: 40.0, target: self, selector: #selector(startCancelledApiTimer(_:)), userInfo: nil, repeats: false)
                }
                if  dict["msg"] as? String == "Payment has been received successfully."{
                 //   kNotificationAction = "COMPLETED"
                    self.showAlert("GetDuma Driver", message: "$" + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is received successfully")
                   getLastRideDataApi()
                }
            }
            if let dictDataRideID = dict["ride_id"] as? String{
                print(dictDataRideID)
                kRideId = dictDataRideID
            }
        }
    }
    @objc func loadForegroundList(_ notification: NSNotification){
        let notificationData = notification.userInfo
        if let dict = notificationData as? [String: Any] {
            print("userInfo: ", dict)
            if let dictData = dict["action"] as? String{
                print(dictData)
                kNotificationAction = dictData
                if kNotificationAction == "PENDING"{
                    self.pendingRequestApi()
                  //  timer = Timer.scheduledTimer(timeInterval: 40.0, target: self, selector: #selector(startCancelledApiTimer(_:)), userInfo: nil, repeats: false)
                }
                if  dict["msg"] as? String == "Payment has been received successfully."{
//                    kNotificationAction = "COMPLETED"
                    self.showAlert("GetDuma Driver", message: "$" + "\(self.lastRideData?.amount  ?? "")"  + " " + "Amount is received successfully")
                   getLastRideDataApi()
                   
                }
            }
            if let dictDataRideID = dict["ride_id"] as? String{
                print(dictDataRideID)
                kRideId = dictDataRideID
            }
        }
    }
    @objc func startCancelledApiTimer(_ timer: Timer) {
        print("Cancelled Timer Start")
        if kNotificationAction == "PENDING" || kConfirmationAction  == "PENDING" {
            self.cancelRideStatus(rideId: kRideId)
        }
    }
    
    @IBAction func startRecordBtnAction(_ sender: Any) {
        var playBtn = sender as! UIButton
        if toggleState == 1 {
            //  player.play()
            toggleState = 2
            playBtn.backgroundColor = UIColor.red
            playBtn.setTitle("Stop Record", for: .normal)
            showToast(message: "Recording Started")
            startRecording()
        } else {
            // player.pause()
            toggleState = 1
            playBtn.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.6235294118, blue: 0.1647058824, alpha: 1)
            playBtn.setTitle("Start Record", for: .normal)
            showToast(message: "Recording Stopped")
            finishRecording(success: true)
        }
    }
    
    @IBAction func navigateBtnAction(_ sender: Any) {
        navigateBTN()
//        let pickLat = self.lastRideData?.drop_lat  ?? ""
//        let pickLong = self.lastRideData?.drop_long  ?? ""
//        let lat =  Double(pickLat)
//        let long =  Double(pickLong)
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
//            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(pickLat),\(pickLong)&directionsmode=driving") {
//                UIApplication.shared.open(url, options: [:])
//            }}
//        else {
//            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
//                UIApplication.shared.open(urlDestination)
//            }
//        }
    }
    func navigateBTN(){
      
        let pickLat = self.lastRideData?.drop_lat  ?? ""
        let pickLong = self.lastRideData?.drop_long  ?? ""
        let lat =  Double(pickLat)
        let long =  Double(pickLong)
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(pickLat),\(pickLong)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }}
        else {
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
    @IBAction func completeRideBtnAction(_ sender: Any) {
        kConfirmationStatus = "COMPLETED"
        acceptRejectStatus(confirmStatus: kConfirmationStatus, acceptRejectView: acceptReject.completedStatus)
        
    }
    @IBAction func trackBtnAction(_ sender: Any) {
        trackBT()
//        print(kCurrentLocaLatLong)
//        print(kDestinationLatLong)
//        routingLines(origin: kCurrentLocaLatLong,destination: kDestinationLatLong)
//        //  getPolylineRoute(source: kCurrentLocaLatLong, destination: kDestinationLatLong)
//        print("track")
//        let pickLat = self.lastRideData?.pickup_lat ?? ""
//        let pickLong = self.lastRideData?.pickup_long ?? ""
//        let lat =  Double(pickLat)
//        let long =  Double(pickLong)
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
//            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(pickLat),\(pickLong)&directionsmode=driving") {
//                UIApplication.shared.open(url, options: [:])
//            }}
//        else {
//            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
//                UIApplication.shared.open(urlDestination)
//            }
//        }
    }
    func trackBT(){
        print(kCurrentLocaLatLong)
        print(kDestinationLatLong)
        routingLines(origin: kCurrentLocaLatLong,destination: kDestinationLatLong)
        //  getPolylineRoute(source: kCurrentLocaLatLong, destination: kDestinationLatLong)
        print("track")
        let pickLat = self.lastRideData?.pickup_lat ?? ""
        let pickLong = self.lastRideData?.pickup_long ?? ""
        let lat =  Double(pickLat)
        let long =  Double(pickLong)
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(pickLat),\(pickLong)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }}
        else {
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
    
    @IBAction func callBtnAction(_ sender: Any) {
      //  kCustomerMobile.makeCall(phoneNumber: kCustomerMobile)
        makecall()
    }
    func makecall(){
       // showIndicator()
        Indicator.shared.showProgressView(self.view)
        
        let cc = NSUSERDEFAULT.value(forKey: kownCcode)
        let mobile =  NSUSERDEFAULT.value(forKey: kownMobile)
        
        let requestParams: [String: Any] = ["Caller": mobile ?? "", "country_code" : cc ?? ""]
        let urlString = "https://www.getduma.com/twilio/forward_call"
        let url = URL.init(string: urlString)
        print(url)
        print(requestParams)
        let AF = Session.default
       
        AF.request(urlString, method: .post, parameters: requestParams, encoding: URLEncoding.default)
            .response { response in
                Indicator.shared.hideProgressView()
                print("responseString: \(response)")
             //   self.hideIndicator()
               
                switch (response.result) {
                case .success(let response):
                    do {
                        if let json = try JSONSerialization.jsonObject(with: response!, options: []) as? [String: Any] {
                            self.showAlert("GetDuma Driver", message: "Our team will call you shorty.")
                            // try to read out a string array
                            let status = json["message"] as? String

                            
                           // print(status)
                           
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                      break
                    
                case .failure(let error):
                    print(error)
                    
                    self.showAlert("GetDuma", message: "\(error.localizedDescription)")
                    break
                }
            }
    }
    
    @IBAction func startBtnAction(_ sender: Any) {
//        startRideView.isHidden = true
//        accptRejectView.isHidden = true
//        recordView.isHidden = false
        kConfirmationStatus = "START_RIDE"
        UpdateLotLng()
        acceptRejectStatus(confirmStatus: kConfirmationStatus, acceptRejectView: acceptReject.startRideStatus)
    }
    @IBAction func acceptBtnAction(_ sender: Any) {
        
        self.timer?.invalidate()
        self.timer = nil
        self.progressView.progress = 0.0
        kConfirmationStatus = "ACCEPTED"
//        accptRejectView.isHidden = true
//        startRideView.isHidden = false
//        recordView.isHidden = true
        UpdateLotLng()
        acceptRejectStatus(confirmStatus: kConfirmationStatus, acceptRejectView: acceptReject.acceptStatus)
        
    }
    
    @IBAction func rejecttBtnAction(_ sender: Any) {
        kConfirmationStatus = "CANCELLED"
        acceptRejectViewCase = acceptReject.cancelStatus
        startRideView.isHidden = true
        accptRejectView.isHidden = true
        confirmationView.isHidden = true
        recordView.isHidden = true
        acceptRejectStatus(confirmStatus: kConfirmationStatus, acceptRejectView: acceptReject.cancelStatus)
    }
    @IBAction func switchToggled(_ sender: UISwitch) {
        DispatchQueue.main.async {
            NavigationManager.pushToLoginVC(from: self)
        }
        
        if self.toggalBTN == ""{
            if self.change_vehicle == "yes"{
                my_switch.isOn = false
                self.showAlert("Getdume", message: "Your vehicle is exipre.\nPlease change your vehicle")
            }else if self.Doc_Exp == "yes"{
                my_switch.isOn = false
                self.showAlert("Getdume", message: "Your Document is exipre.\nPlease Update your Document")
            }else if self.Doc_Pend == "yes"{
                my_switch.isOn = false
                self.showAlert("Getdume", message: "Your approval is still pending. We \nwill update you within 48 hours.")
            }else{
                if sender.isOn {
                    print( "The switch is now true!" )
                    NSUSERDEFAULT.set("1", forKey: kUpdateDriveStatus)
                    offlineOnlineLabel.text = "Online"
                    onOffStatus = onOff.online
                    my_switch.onTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    offlineOnlineBtn.setTitle("Online", for: .normal)
                    offlineOnlineBtn.backgroundColor = UIColor(named: "green")
                    selectServicesStatus = .isSelected
                    self.updateStatus(updateStatus: "1")
                    UIApplication.shared.isIdleTimerDisabled = true
                }else{
                    print( "The switch is now false!" )
                    NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
                    offlineOnlineLabel.text = "Offline"
                    onOffStatus = onOff.offline
                    my_switch.onTintColor = UIColor.clear
                    offlineOnlineBtn.setTitle("Offline", for: .normal)
                    offlineOnlineBtn.backgroundColor = UIColor.red
                    selectServicesStatus = .isNotSelected
                    self.updateStatus(updateStatus: "3")
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
        }else{
            my_switch.isOn = false
            self.showAlert("GetDuma Driver", message: toggalBTN)
        }
    }
    @IBAction func markAsReceivedBtn(_ sender: Any) {
        print("Received")
        self.receivedMark()
    }
    
    
    @IBAction func offOnBtnAction(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            NavigationManager.pushToLoginVC(from: self)
        }
        if self.toggalBTN == ""{
            if self.change_vehicle == "yes"{
                self.showAlert("Getdume", message: "Your vehicle is exipre.\nPlease change your vehicle")
            }else if self.Doc_Exp == "yes"{
                my_switch.isOn = false
                self.showAlert("Getdume", message: "Your Document is exipre.\nPlease Update your Document")
            }else if self.Doc_Pend == "yes"{
                my_switch.isOn = false
                self.showAlert("Getdume", message: "Your approval is still pending. We \nwill update you within 48 hours.")
            }else{
                sender.isSelected = !sender.isSelected
                if sender.isSelected {
                    print("Offline")
                    sender.backgroundColor = UIColor.red
                    NSUSERDEFAULT.set("3", forKey: kUpdateDriveStatus)
                    offlineOnlineLabel.text = "Offline"
                    onOffStatus = onOff.offline
                    my_switch.onTintColor = UIColor.clear
                    offlineOnlineBtn.setTitle("Offline", for: .normal)
                    offlineOnlineBtn.backgroundColor = UIColor.red
                    my_switch.isOn = false
                    selectServicesStatus = .isNotSelected
                    self.updateStatus(updateStatus: "3")
                    UIApplication.shared.isIdleTimerDisabled = false
                } else {
                    print("Online")
                    sender.backgroundColor = UIColor.green
                    NSUSERDEFAULT.set("1", forKey: kUpdateDriveStatus)
                    offlineOnlineLabel.text = "Online"
                    onOffStatus = onOff.online
                    my_switch.onTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    offlineOnlineBtn.setTitle("Online", for: .normal)
                    offlineOnlineBtn.backgroundColor = UIColor(named: "green")
                    my_switch.isOn = true
                    selectServicesStatus = .isSelected
                    self.updateStatus(updateStatus: "1")
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
        }else{
            self.showAlert("GetDuma Driver", message: toggalBTN)
        }
       
    }
    @objc func changeRideTimer(_ timer: Timer) {
        print("CHANGE RIDE CALLING")
        self.changeRideStatus(rideId: kRideId, status: "PENDING")
    }
    @objc func pendingViewAutomatically(){
        self.pendingRequestApi()
    }
    @objc func cancelAutomatically(){
        var timerCountStatus = false
        if kRideId != "" && timerCountStatus == false {
            print("work 3 minutes")
            timerCountStatus = true
            if  kNotificationAction == "PENDING" && kConfirmationAction == "PENDING" {
                self.cancelRideStatus(rideId: kRideId)
            }
        }
        
    }
    @objc func onReceiveData(_ notification:Notification) {
        // Do something now //reload tableview
    }
    //MARK:- payemnt recived popup 
    func receivedMark() {
        let refreshAlert = UIAlertController(title: "Alert" , message: "Do you want to receive payment via Cash?", preferredStyle: UIAlertController.Style.alert)
       
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
            if kRideId != "" {
                self.markReceivedApi(rideId: kRideId, updateDriverStatus: "1")
            }
         
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
}
extension StringProtocol  {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}
