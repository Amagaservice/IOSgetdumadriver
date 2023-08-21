//
//  LoginViewController.swift
//  OcoryDriver
//
//  Created by Arun Singh on 10/03/21.
//

import UIKit
import Alamofire
class LoginViewController: UIViewController {
    
    //MARK:- OUTLETS
    @IBOutlet weak var email_txtField: UITextField!
    @IBOutlet weak var password_txtField: UITextField!
    
    //MARK:- Variables
    let conn = webservices()
  //  var profileDetails : ProfileData?
    var customerData : userCustomerModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        email_txtField.setLeftPaddingPoints(20)
        password_txtField.setLeftPaddingPoints(20)

        self.navigationController?.isNavigationBarHidden = true
        //   email_txtField.text = "testernile6@gmail.com"
        //    password_txtField.text = "abc@123"
        
        //   email_txtField.text = "saurabh.chaubey@niletechnologies.com"
        //   password_txtField.text = "pass@123"
        
        //        email_txtField.text = "ajaydd@gmail.com"
        //        password_txtField.text = "fsdfsdf"
        // email_txtField.text = "user@gmail.com"
        //   password_txtField.text = "test@123"
        //    email_txtField.text = "Testernile9@gmail.com"
        //    password_txtField.text = "abc@123"
        //  email_txtField.text = "userajay@gmail.com"
        // password_txtField.text = "test@123"
        //
        //      email_txtField.text = "mondaydriver@gmail.com"
        //     password_txtField.text = "abc@123"
    }
    
    //MARK:- Button Action
    @IBAction func tapForgetPass_btn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SendOTPViewController") as! SendOTPViewController
        vc.modalPresentationStyle = .overFullScreen
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func tapSignUp_btn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func tapLogin_btn(_ sender: Any) {
        
      
        
        if self.email_txtField.text == ""{
            self.showAlert("GetDuma Driver", message: "Please enter email address")
        }else if !(Validation().isValidEmail(self.email_txtField.text!)){
            self.showAlert("GetDuma Driver", message: "Please enter valid email address")
        }else if self.password_txtField.text == ""{
            self.showAlert("GetDuma Driver", message: "Please enter password")
        }else {
            self.loginApi()
        }
    }
}
//MARK:- Web Api
extension LoginViewController{
    //MARK:- login api
   
    func loginApi(){
        var deviceID =  UIDevice.current.identifierForVendor?.uuidString
        print(deviceID)
        let gcm_token = AppDelegate.fcmToken
        NSUSERDEFAULT.setValue(gcm_token, forKey: kFcmToken)
        let param = ["email":self.email_txtField.text!,"password":self.password_txtField.text!,"device_token": deviceID ?? "", "device_type": "ios", "utype":2 , "gcm_token" :  NSUSERDEFAULT.value(forKey: kFcmToken) as? String ?? ""] as [String : Any]
        print(param)
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithPostType(getUrlString: "login", params: param) { (value) in
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print(value)
                let msg = (value["message"] as? String ?? "")
                if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: value["data"] as? [String:Any] ?? "", requiringSecureCoding: false) {
                    UserDefaults.standard.set(savedData, forKey: "loginInfo")
                }
                if ((value["status"] as? Int ?? 0) == 1){
                    let token = (value["token"] as? String ?? "")
                    let data = (value["data"] as? [String:Any] ?? [:])
                    let userId = (data["user_id"] as? String ?? "")
                    let gcm = (data["gcm_token"] as? String ?? "")
                    let country_code = (data["country_code"] as? String ?? "")
                    let mobile = (data["mobile"] as? String ?? "")
                   // var mobileno = country_code + mobile
                    NSUSERDEFAULT.set(country_code, forKey: kownCcode)
                    NSUSERDEFAULT.set(mobile, forKey: kownMobile)
                    NSUSERDEFAULT.setValue(gcm, forKey: kDeviceToken)
                    NSUSERDEFAULT.set(token, forKey: accessToken)
                    NSUSERDEFAULT.set(userId, forKey: kUserID)
                    NSUSERDEFAULT.setValue(self.password_txtField.text!, forKey: kPassword)
                    NSUSERDEFAULT.set(true, forKey: kUserLogin)
                    UserDefaults.standard.synchronize()
                   self.getDocexpiry()
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.showAlert("GetDuma Driver", message: msg)
                }
            }
        }
    }
    //MARK:- check expiry document api 
    func getDocexpiry() {
        Indicator.shared.showProgressView(self.view)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + (UserDefaults.standard.value(forKey: "token") as? String ?? ""),
            "Content-type": "multipart/form-data"]
        
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: "get_check_document_expiry",authRequired: true) { (value) in
            // print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                print("Getting Profile Data Api  \(value)")
                let msg = (value["license_expiry"] as? Bool ?? true)
                if value["license_expiry"] as? Bool == false || value["insurance_expiry"] as? Bool == false || value["identification_expiry"] as? Bool == false || value["inspection_expiry"] as? Bool == false{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "welcomeVCID") as! welcomeVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                print("")
//                if (value["status"] as? Int ?? 0) == 1{
//                    var data = (value["data"] as? [String:Bool] ?? [:])
//                    do{
////                        let response = try? JSONDecoder().decode([String: Bool].self, from: data)
////                        if response?["license_expiry"] == true {
//
//                        let jsondata = try JSONSerialization.data(withJSONObject: data , options: .prettyPrinted)
//                        let encodedJson = try JSONDecoder().decode(userCustomerModal.self, from: jsondata)
//                        self.customerData = encodedJson
//
//                        if self.customerData?.license_expiry == true{
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewControllerID") as! HomeViewController
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }else{
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "welcomeVCID") as! welcomeVC
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                      //  self.servicesList.reloadData()
//                    }catch{
//                        print(error.localizedDescription)
//                    }
//                }
//                else{
//                    guard let stat = value["Error"] as? String, stat == "ok" else {
//                        // self.showToast(message: "\(String(describing: stat))")
//                        return
//                    }
//                }
            }
        }
    }
}
