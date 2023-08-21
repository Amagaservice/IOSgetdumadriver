//
//  SignUpViewController.swift
//  OcoryDriver
//
//  Created by Arun Singh on 12/03/21.
//

import UIKit
import iOSDropDown
import CoreLocation
import GoogleMaps
import GooglePlaces

class SignUpViewController: UIViewController  {
    //MARK:- OUTLETS
    
    
    @IBOutlet var mCountryTF: UITextField!
    @IBOutlet var mAddressTF: UITextField!
    @IBOutlet weak var mDocumentTF: UITextField!
    @IBOutlet weak var mDOBTF: UITextField!
    @IBOutlet weak var mTextFLD: UITextView!
    @IBOutlet weak var name_txtField: UITextField!
    @IBOutlet weak var email_txtField: UITextField!
    @IBOutlet weak var password_txtField: UITextField!
    @IBOutlet weak var cnfPass_txtField: UITextField!
    @IBOutlet weak var mobile_txtField: UITextField!
    @IBOutlet weak var selectVehicleCompName_txtField: UITextField!
    @IBOutlet weak var selectVehicleModelName_txtField: UITextField!
    @IBOutlet weak var selectYear_txtField: UITextField!
    @IBOutlet weak var vehicleNo_txtField: UITextField!
    @IBOutlet weak var vehicleColor_txtField: UITextField!
  //  @IBOutlet weak var vehicleType_txtField: UITextField!
    @IBOutlet weak var mExpirydateTF: UITextField!
    @IBOutlet weak var mIssueDateTF: UITextField!
 //   @IBOutlet weak var insuranceImageView: UIImageView!
    @IBOutlet weak var ProfilePicIMG: UIImageView!
    @IBOutlet weak var carPicImageView: UIImageView!
    @IBOutlet weak var identityIMG: UIImageView!
    @IBOutlet weak var selectSeats_txtField: UITextField!
    @IBOutlet weak var SSNo_txtField: UITextField!
    @IBOutlet weak var mViewforCheckBoxTOP: NSLayoutConstraint!
    @IBOutlet weak var mViewforcheckbox: UIView!
    @IBOutlet weak var mLuxurySeatsBTN: UIButton!
    @IBOutlet weak var mTVBTN: UIButton!
    @IBOutlet weak var mWIFIBTN: UIButton!
    let conn = webservices()
    var params = [String:Any]()
    var genderSelect = ["Male","Female"]
    var brandData = [BrandDetails]()
   // var brandData = [BrandDetails]()

    var modelData = [ModelDetails]()
    var vehicleTypeData = [vehicleDetail]()
    var docModel = [CompletedRidesData]()
    var brandId = 0
    var modalId = ""
    var vehicleTypeId = 0
    var imageData : Data?
    var imageName : String?
    var img : UIImage?
    var imageURLOne = ""
    var imageURLTwo = ""
    var imageURLThree = ""
    var imageURLFour = ""
    var vCarImg : UIImage?
    var vProfilePic : UIImage?
    var videntityIMG : UIImage?
    //var insuranceImg = UIImage()
    var YearTF = ["2022","2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"]
    var selectSeatsTF = ["4","5","6","7","8","above 8"]
    var selectYearpickerView = UIPickerView()
    var selectSeatsPickerView = UIPickerView()
    
    var brandDataPickerView = UIPickerView()
    var modelDataPickerView = UIPickerView()
    var vehicleTyPickerView = UIPickerView()
    var DocumnetsPickerView = UIPickerView()
    var brandIdString = String()
    var selectedDocID = String()
//    enum imagePic {
//        case imageInsurance
//        case imageLicense
//        case imageCarPic
//        case identityIMG
//    }
    var DOBdatePicker = UIDatePicker()
    var datePicker = UIDatePicker()
    var datePicker2 = UIDatePicker()
    
    var counPicker = CountryPicker()

    var imagePickStatus =  ""
    lazy var imagePicker :ImagePickerViewControler  = {
        return ImagePickerViewControler()
    }()
    //MARK:- Variables
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getBrandsApi()
        self.getdoc()
        picker()
        SSNo_txtField.delegate = self
        mCountryTF.inputView = counPicker
        self.counPicker.countryPickerDelegate = self
        self.counPicker.showPhoneNumbers = true
        mDOBTF.setLeftPaddingPoints(20)
        SSNo_txtField.setLeftPaddingPoints(20)
        mDocumentTF.setLeftPaddingPoints(20)
        mobile_txtField.setLeftPaddingPoints(50)
        print("FCM TOKEN IS HERE \(String(describing: NSUSERDEFAULT.value(forKey: kFcmToken) as? String ?? ""))")
//        self.selectYear_txtField.optionArray = ["Select Vehicle Year","2022","2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"]
//        self.selectSeats_txtField.optionArray = ["Select Number of Seats","2","4","6","8"]
        
        mAddressTF.delegate = self
      //  mAddressTF.addTarget(self, action: #selector(locationTextFieldTapped(_:)), for: .touchDown)
        
        
    }
    
    
    // Selector Method
//    @objc func locationTextFieldTapped(_ textField: UITextField) {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        present(autocompleteController, animated: true, completion: nil)
//       // }
////        let storyboard = GTStoryboard.dashboard.storyboard
////        guard let searchLocationVC = storyboard.instantiateViewController(withIdentifier: GTStoryboardId.searchLocationViewController) as? SearchLocationViewController else {
////            return
////        }
////        searchLocationVC.delegate = self
////        searchLocationVC.modalPresentationStyle = .fullScreen
////        self.navigationController?.present(searchLocationVC, animated: true, completion: nil)
//    }
    
    
    //MARK picker
    func picker(){
        selectYearpickerView.delegate = self
        selectSeatsPickerView.delegate = self
        brandDataPickerView.delegate = self
        modelDataPickerView.delegate = self
        vehicleTyPickerView.delegate = self
        DocumnetsPickerView.delegate = self
        
        
        mTextFLD.text = "Home Address"
        mTextFLD.textColor = UIColor.lightGray
        mTextFLD.delegate = self
        mWIFIBTN.setImage(UIImage(named: "uncheck"), for: .normal)
        mTVBTN.setImage(UIImage(named: "uncheck"), for: .normal)
        mLuxurySeatsBTN.setImage(UIImage(named: "uncheck"), for: .normal)
        mViewforcheckbox.isHidden = true
        mViewforCheckBoxTOP.constant = -40
        
        selectVehicleModelName_txtField.inputView = vehicleTyPickerView
        selectSeats_txtField.inputView = selectSeatsPickerView
        selectVehicleCompName_txtField.inputView = modelDataPickerView
        selectYear_txtField.inputView = selectYearpickerView
        mDocumentTF.inputView = DocumnetsPickerView
        mExpirydateTF.setLeftPaddingPoints(20)
        mIssueDateTF.setLeftPaddingPoints(20)
        
        mDOBTF.delegate = self
        mIssueDateTF.delegate = self
        mExpirydateTF.delegate = self
        name_txtField.delegate = self
        selectVehicleCompName_txtField.delegate = self
        selectVehicleModelName_txtField.delegate = self
        selectSeats_txtField.delegate = self
    }
    //MARK:- date picker
    func showDatePicker(){
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker2.preferredDatePickerStyle = .wheels
            DOBdatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        DOBdatePicker.datePickerMode = .date
        DOBdatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -21, to: Date())
        DOBdatePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -65, to: Date())

        mDOBTF.inputView = DOBdatePicker
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        mIssueDateTF.inputView = datePicker
        
        datePicker2.datePickerMode = .date
        datePicker2.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        mExpirydateTF.inputView = datePicker2
    }
    
    
    //MARK:- User Defined Func
    @IBAction func tapSignIn_btn(){
//        let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
//        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tapGoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tapSignUp_btn(){
        self.validationsCheck()
    }
    //MARK:- Button Action
    @IBAction func  identityBTNAC(){
        imagePickStatus = "identity"
//        self.imagePicker.imagePickerDelegete = self
//        self.imagePicker.showImagePicker(viewController: self)
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func ProfilePicBTNAC(){
        imagePickStatus = "profile"
//        self.imagePicker.imagePickerDelegete = self
//        self.imagePicker.showImagePicker(viewController: self)
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func carPicBtnAction(){
        imagePickStatus = "carPic"
//        self.imagePicker.imagePickerDelegete = self
//        self.imagePicker.showImagePicker(viewController: self)
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    //MARK:- open camera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK:- open gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.getBrandsApi()
    }
    
    
    @IBAction func mWIFIbtn(_ sender: Any) {
        if mWIFIBTN.currentImage == UIImage(named: "uncheck"){
            mWIFIBTN.setImage(UIImage(named: "check"), for: .normal)
//            mTVBTN.setImage(UIImage(named: "uncheck"), for: .normal)
//            mLuxurySeatsBTN.setImage(UIImage(named: "uncheck"), for: .normal)

        }else{
            mWIFIBTN.setImage(UIImage(named: "uncheck"), for: .normal)

        }
    }
    
    @IBAction func aTVbtn(_ sender: Any) {
        if mTVBTN.currentImage == UIImage(named: "uncheck"){
          //  mWIFIBTN.setImage(UIImage(named: "uncheck"), for: .normal)
            mTVBTN.setImage(UIImage(named: "check"), for: .normal)
        //    mLuxurySeatsBTN.setImage(UIImage(named: "uncheck"), for: .normal)

        }else{
            mTVBTN.setImage(UIImage(named: "uncheck"), for: .normal)

        }
    }
    
    @IBAction func aluxuryseats(_ sender: Any) {
        
        if mLuxurySeatsBTN.currentImage == UIImage(named: "uncheck"){
//            mWIFIBTN.setImage(UIImage(named: "uncheck"), for: .normal)
//            mTVBTN.setImage(UIImage(named: "uncheck"), for: .normal)
            mLuxurySeatsBTN.setImage(UIImage(named: "check"), for: .normal)

        }else{
            mLuxurySeatsBTN.setImage(UIImage(named: "uncheck"), for: .normal)

        }
        
    }
    
   // get data
//    func getdataApi() f
    
}
extension SignUpViewController: UITextViewDelegate{
    
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       //  if textField == mCardNumTF{
             
             if textField == SSNo_txtField{
                 let str = textField.text!
                 let  char = string.cString(using: String.Encoding.utf8)!
                 let isBackSpace = { return strcmp(char, "\\b") == -92}

                 if (str.count == 3 && !isBackSpace()) || (str.count == 6 && !isBackSpace()){
                     textField.text = textField.text! + "-"
                 }

                 if (str.count) == 11 && !isBackSpace(){
                     SSNo_txtField.text = str
                     self.view.endEditing(true)

                 }
             }
         
         if textField == name_txtField{
             var ACCEPTABLE_CHARACTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
             if range.location == 0 && string == " " { // prevent space on first character
                 return false
             }
             if textField.text?.last == " " && string == " " { // allowed only single space
                 return false
             }
             let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTER).inverted
             let filtered = string.components(separatedBy: cs).joined(separator: "")
             return (string == filtered)
         }
         
         
         //}
         return true
     }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if mTextFLD.textColor == UIColor.lightGray {
            mTextFLD.text = nil
            mTextFLD.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if mTextFLD.text.isEmpty {
            mTextFLD.text = "Home Address"
            mTextFLD.textColor = UIColor.lightGray
        }
    }
}
extension SignUpViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if textField == selectVehicleModelName_txtField{
            if selectVehicleCompName_txtField.text == "Select Vehicle Make"{
                self.showAlert("GetDuma Driver", message: "Please select vehicle make")
                return false
            }else{
                return true
            }
        }
        // Do not add a line break
        return true
     }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mIssueDateTF{
            showDatePicker()
        }else if textField == mExpirydateTF{
            showDatePicker()
          //  mEndDateTXTFLD.text = ""
        }else if textField == mDOBTF{
            showDatePicker()
        }else if textField == selectVehicleCompName_txtField{
            selectVehicleModelName_txtField.text = "Select Vehicle Model"
        }else if textField == mAddressTF{
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mIssueDateTF {
            let selectedDate = datePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.mIssueDateTF.text = formatter.string(from: selectedDate)
        }else if textField == mExpirydateTF {
            let selectedDate = datePicker2.date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.mExpirydateTF.text = formatter.string(from: selectedDate)
        }else if textField == mDOBTF {
            let selectedDate = DOBdatePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.mDOBTF.text = formatter.string(from: selectedDate)
        }else if textField == selectVehicleCompName_txtField{
        //    let brandIdString:String = self.brandData[index].id  ?? ""
            if selectVehicleCompName_txtField.text != "Select Vehicle Make"{
                self.brandId = Int(brandIdString)!
                self.getModelApi()
            }
        }else if textField == selectSeats_txtField{
            if selectSeats_txtField.text == "8" {
                mViewforcheckbox.isHidden = false
                mViewforCheckBoxTOP.constant = 20
            }else{
                
                mViewforcheckbox.isHidden = true
                mViewforCheckBoxTOP.constant = -40
            }
        }
    }
}
extension SignUpViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == selectYearpickerView{
            return YearTF.count
        }else if pickerView == modelDataPickerView{
            return brandData.count
        }else if pickerView == vehicleTyPickerView{
            return modelData.count
        }else if pickerView == DocumnetsPickerView{
            return docModel.count
        }else{
            return selectSeatsTF.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == selectYearpickerView{
            return YearTF[row]
        }else if pickerView == modelDataPickerView{
            return brandData[row].brandName
        }else if pickerView == vehicleTyPickerView{
            return modelData[row].modelName
        }else if pickerView == DocumnetsPickerView{
            return docModel[row].document_name
        }else{
            return selectSeatsTF[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == selectYearpickerView{
            selectYear_txtField.text = YearTF[row]
        }else if pickerView == modelDataPickerView{
            selectVehicleCompName_txtField.text =  brandData[row].brandName
            brandIdString =  brandData[row].id!
        }else if pickerView == vehicleTyPickerView{
            if modelData.count != 0{
                selectVehicleModelName_txtField.text = modelData[row].modelName
                modalId = modelData[row].id!
            }
           
            
        }else if pickerView == DocumnetsPickerView{
            mDocumentTF.text = docModel[row].document_name
            selectedDocID = docModel[row].id!
        }else if pickerView == selectSeatsPickerView{
            selectSeats_txtField.text = selectSeatsTF[row]
        }
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("calling")
           
//            if imagePickStatus == .imageInsurance {
//                insuranceImageView.image = pickedImage
//                self.insuranceImg = pickedImage
//
//            }
            if imagePickStatus == "profile"{
                ProfilePicIMG.image = pickedImage
                self.vProfilePic = pickedImage
                
            }
            if imagePickStatus == "carPic"{
                self.carPicImageView.image = pickedImage
                self.vCarImg = pickedImage
                
            }
            if imagePickStatus == "identity"{
                identityIMG.image = pickedImage
                self.videntityIMG = pickedImage
              
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
  
}
////MARK:- Image Picker Delegate
//extension SignUpViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate , ImagePickerDelegete {
//    func disFinishPicking(imgData: Data, img: UIImage) {
//        self.imageData = imgData
//        self.imageName =  String.uniqueFilename(withSuffix: ".png")
//        self.img = img
//        if self.img != nil{
//            let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
//            let userDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
//            let paths             = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
//            if let dirPath        = paths.first
//            {
//                if imagePickStatus == .imageInsurance {
//                    insuranceImageView.image = self.img
//                     imageURLOne = "\(URL(fileURLWithPath: dirPath).appendingPathComponent("name1.jpg"))"
//                }
//                if imagePickStatus == .imageLicense{
//                    licenseImageView.image = self.img
//                     imageURLTwo = "\(URL(fileURLWithPath: dirPath).appendingPathComponent("name2.jpg"))"
//                }
//                if imagePickStatus == .imageCarPic{
//                    carPicImageView.image = self.img
//                    imageURLThree = "\(URL(fileURLWithPath: dirPath).appendingPathComponent("name3.jpg"))"
//                }
//                if imagePickStatus == .identityIMG{
//                    carRegistrationImageView.image = self.img
//                    imageURLFour = "\(URL(fileURLWithPath: dirPath).appendingPathComponent("name4.jpg"))"
//                }
//            }
//        }
//    }
//}

extension SignUpViewController {
    //MARK:- valodation check 
    func validationsCheck(){
        guard let name = name_txtField.text, name != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Name")
            return
        }
        guard let email = email_txtField.text, email != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Email")
            return
        }
        guard let pass = password_txtField.text, pass != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Password")
            return
        }
        guard let cpass = cnfPass_txtField.text, cpass != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Confirm Password")
            return
        }
        guard let mobile = mobile_txtField.text, mobile != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Mobile Number")
            return
        }
//        guard let SSN = SSNo_txtField.text, SSN != "" else {
//            self.showAlert(Singleton.shared!.title, message: "Enter SSN Number")
//            return
//        }
        guard let DOB = mDOBTF.text, DOB != "" else {
            self.showAlert(Singleton.shared!.title, message: "Enter Date of birth")
            return
        }
        //    guard let vehicleMake = selectVehcileMake_txtField.text, vehicleMake != "" else {
        //     self.showAlert(Singleton.shared!.title, message: "Please Select Vehicle Make")
        //     return
        //  }
        
        //        guard let vehicleYear = selectVehicleYear_txtField.text, vehicleYear != "" else {
        //            self.showAlert(Singleton.shared!.title, message: "Please Select Vehicle Year")
        //            return
        //        }
        guard let brand = selectVehicleCompName_txtField.text, brand != "Select Vehicle Make" else {
            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Make")
            return
        }
        guard let model = selectVehicleModelName_txtField.text, model != "Select Vehicle Model" else {
            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Model")
            return
        }
        guard let year = selectYear_txtField.text, year != "Select Vehicle Year" else {
            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Year")
            return
        }
        guard let vehicleColor = vehicleColor_txtField.text, vehicleColor != "" else {
            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Color")
            return
        }
        guard let vehicleSeats = selectSeats_txtField.text, vehicleSeats != "Select Number of Seats" else {
            self.showAlert(Singleton.shared!.title, message: "Select Number of Seats")
            return
        }
//        guard let vehicle_type = vehicleType_txtField.text, vehicle_type != "Select Vehicle Type" else {
//            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Type")
//            return
//        }
        guard let vehicleNumber = vehicleNo_txtField.text, vehicleNumber != "" else {
            self.showAlert(Singleton.shared!.title, message: "Select Vehicle Number plate")
            return
        }
        if password_txtField.text!.count < 5{
            self.showAlert(Singleton.shared!.title, message: "Password should contain at least 6 characters")
            return
        }
        if password_txtField.text != cnfPass_txtField.text {
            self.showAlert(Singleton.shared!.title, message: "Password and Confirm Password does not match")
            return
        }
//        if SSNo_txtField.text!.count < 8{
//            self.showAlert(Singleton.shared!.title, message: "SSNumber  should contain at least 9 characters")
//            return
//        }
        
//        var vCarImg : UIImage?
//        var vProfilePic : UIImage?
//        var videntityIMG : UIImage?
        
        if vProfilePic == nil{
            self.showAlert(Singleton.shared!.title, message: "Please select profile pic")
            return
        }
        if vCarImg == nil{
            self.showAlert(Singleton.shared!.title, message: "Please select car pic")
            return
        }
        if mDocumentTF.text == ""{
            self.showAlert(Singleton.shared!.title, message: "Please select identity document")
            return
        }
        if videntityIMG == nil{
            self.showAlert(Singleton.shared!.title, message: "Please select identity pic")
            return
        }
        if mIssueDateTF.text == "" {
            self.showAlert(Singleton.shared!.title, message: "Please select issue date")
            return
        }
        if mExpirydateTF.text == "" {
            self.showAlert(Singleton.shared!.title, message: "Please select expiry date")
            return
        }
           
        
        
        
        
        if email.isValidEmail(testStr: email) == false {
            self.showAlert(Singleton.shared!.title, message: "Email is invalid")
        }else  {
            print("hit api")
            self.uploadPhotoGallaryNewSignup(media: self.vCarImg!, mediaLicense: self.videntityIMG! , mediaIdentity: self.vProfilePic!)
          //  self.hitSignUpApi()
        }
    }
}


extension SignUpViewController: CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(String(describing: place.name))")
        print("Place placeID: \(String(describing: place.placeID))")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place address: \(String(describing: place.addressComponents))")
        
      //  mAddressTF.textColor = UIColor.black
        
        mAddressTF.text = place.formattedAddress
        
        let coordinate = place.coordinate
           let latitude = coordinate.latitude
           let longitude = coordinate.longitude
        
        let dict = ["address1": place.formattedAddress ?? "", "address2": place.formattedAddress ?? "" , "latitude" : latitude , "longitude" : longitude ] as [String : Any]
        UserDefaults.standard.set(dict, forKey: "SavedCurrentLocation")
        
        
        
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController : CountryPickerDelegate{
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        self.mCountryTF.text = phoneCode
    }
}
