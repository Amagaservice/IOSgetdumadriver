//
//  CancelRideVCPopup.swift
//  OcoryDriver
//
//  Created by malika on 03/10/22.
//

import UIKit

protocol CancelRide{
    func CancelRide()
}
class CancelRideVCPopup: UIViewController {

    @IBOutlet weak var mTextView: UITextView!
    let conn = webservices()
    var delegate : CancelRide?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mTextView.layer.cornerRadius = 10
        mTextView.layer.borderColor = #colorLiteral(red: 0.5058823529, green: 0.7411764706, blue: 0.09803921569, alpha: 1)
        mTextView.layer.borderWidth = 0.5
        mTextView.clipsToBounds = true
        
        
        
        mTextView.contentInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        mTextView.delegate = self
        mTextView.text = "Please write reason"
        mTextView.textColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mYesBTN(_ sender: Any) {
        if mTextView.text != "Please write reason"{
            acceptRejectStatus()
        }else{
            self.showAlert("GetDuma", message: "Please enter write reason")
        }
    }
    @IBAction func mNoBTN(_ sender: Any) {
        self.dismiss(animated: true)
    }
    //MARK:- accept reject ride api 
    func acceptRejectStatus(){
        print("ACCEPT REJECT API")
        let param = [ "ride_id" : kRideId ,"status" : "CANCELLED", "reason" : mTextView.text ?? ""]
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
                
                self.showToast(message: msg)
                self.dismiss(animated: true,completion: {
                    self.delegate!.CancelRide()
                })
            }else{
                self.showAlert("GetDuma Driver", message: msg)
            }
        }
    }
}




extension CancelRideVCPopup : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        if mTextView.textColor == UIColor.lightGray {
           
            mTextView.text = ""
            mTextView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if mTextView.text.isEmpty {
            mTextView.text = "Please write reason"
            mTextView.textColor = UIColor.lightGray
        }
    }
}
