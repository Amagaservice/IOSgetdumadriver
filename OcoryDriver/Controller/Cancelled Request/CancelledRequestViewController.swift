//
//  CancelledRequestViewController.swift
//  OcoryDriver
//
//  Created by Arun Singh on 14/03/21.
//

import UIKit
import CoreLocation

class CancelledRequestViewController: UIViewController {

    //MARK:- OUTLETS
    
    @IBOutlet weak var cancelledReq_tableView: UITableView!
    
    //MARK:- Variables
    var conn = webservices()
    var cancelledRidesData = [CompletedRidesData]()
    
    
    var picupAdd = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelledReq_tableView.dataSource = self
      self.cancelledReq_tableView.delegate = self
     
        self.registerCell()
        self.setNavButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            NavigationManager.pushToLoginVC(from: self)
        }
        self.cancelledRidesDetailsApi()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Cancelled Rides"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.5058823529, green: 0.7411764706, blue: 0.09803921569, alpha: 1)

        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5058823529, green: 0.7411764706, blue: 0.09803921569, alpha: 1)
    }
    func registerCell(){
        let compNib = UINib(nibName: "CompletedRidesTableViewCell", bundle: nil)
        self.cancelledReq_tableView.register(compNib, forCellReuseIdentifier: "CompletedRidesTableViewCell")
    }
    func setNavButton(){
        let logoBtn = UIButton(type: .custom)
        logoBtn.setImage(UIImage(named: "shape_28"), for: .normal)
        logoBtn.addTarget(self, action: #selector(tapNavButton), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: logoBtn)
        self.navigationItem.leftBarButtonItem = barButton
    }
    @objc func tapNavButton(){
        let presentedVC = self.storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController")
        let nvc = UINavigationController(rootViewController: presentedVC)
        present(nvc, animated: false, pushing: true, completion: nil)
    }
}
//MARK:- Table View Datasource
extension CancelledRequestViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.cancelledRidesData.count ) == 0 {
            tableView.setEmptyMessage("No Data Found")
        } else {
            tableView.removeErrorMessage()
        }
        return self.cancelledRidesData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cancelledReq_tableView.dequeueReusableCell(withIdentifier: "CompletedRidesTableViewCell") as! CompletedRidesTableViewCell
        
//         var latt = cancelledRidesData[indexPath.row].pickupLat as! String
//         var lngg = cancelledRidesData[indexPath.row].pickupLong as! String
//         let lat: Double = Double(latt)!
//         let lng: Double = Double(lngg)!
//         let location = CLLocation(latitude: lat, longitude: lng)
//         CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
//                         if error != nil {
//                             return
//                         }else{
//                             let country = placemarks?.first?.country as! String
//                             
//                             let city = placemarks?.first?.locality as! String
//                             let state = placemarks?.first?.administrativeArea as! String
//                             self.picupAdd.append(city)
//                             self.picupAdd.append(state)
//                             self.picupAdd.append(country)
//                             let ab = self.picupAdd.joined(separator: ", ")
//                             cell.pickUpAddress_lbl.text = ab
//                             self.picupAdd.removeAll()
//                         }
//                     })
//         var Dlatt = cancelledRidesData[indexPath.row].dropLat as! String
//         var Dlngg = cancelledRidesData[indexPath.row].dropLong as! String
//         let Dlat: Double = Double(Dlatt)!
//         let Dlng: Double = Double(Dlngg)!
//         let Dlocation = CLLocation(latitude: Dlat, longitude: Dlng)
//         CLGeocoder().reverseGeocodeLocation(Dlocation, completionHandler: {(placemarks, error) -> Void in
//                         if error != nil {
//                             return
//                         }else{
//                             let country = placemarks?.first?.country as! String
//
//                             let city = placemarks?.first?.locality as! String
//                             let state = placemarks?.first?.administrativeArea as! String
//                             self.picupAdd.append(city)
//                             self.picupAdd.append(state)
//                             self.picupAdd.append(country)
//                             let ab = self.picupAdd.joined(separator: ", ")
//                             cell.dropAddress_lbl.text = ab
//                             self.picupAdd.removeAll()
//                         }
//                     })
        cell.pickUpAddress_lbl.text = self.cancelledRidesData[indexPath.row].short_pick_address ?? ""
        cell.dropAddress_lbl.text = self.cancelledRidesData[indexPath.row].short_drop_address ?? ""
        cell.driverName_lbl.text = self.cancelledRidesData[indexPath.row].driverName ?? ""
        cell.date_lbl.text = getStringFormat(date: (self.cancelledRidesData[indexPath.row].time ?? ""))
        cell.time_lbl.text = getStringTimeFormat(date: self.cancelledRidesData[indexPath.row].time ?? "")
    //    cell.amount_lbl.text = "$ " + "\(self.cancelledRidesData[indexPath.row].amount ?? "")"
        return cell
    }
}
//MARK:- Table View Delegate
extension CancelledRequestViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "RideDetailsViewController") as! RideDetailsViewController
        vc.ridesStatusData = self.cancelledRidesData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension CancelledRequestViewController {
    //MARK:- cancel ride api
    func cancelledRidesDetailsApi(){
        let url = "api/user/rides?status=CANCELLED"
        Indicator.shared.showProgressView(self.view)
        self.conn.startConnectionWithGetTypeWithParam(getUrlString: url,authRequired: true) { (value) in
            print(value)
            Indicator.shared.hideProgressView()
            if self.conn.responseCode == 1{
                if (value["status"] as? Int ?? 0) == 1{
                    let data = (value["data"] as? [[String:AnyObject]] ?? [[:]])
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        self.cancelledRidesData = try newJSONDecoder().decode(completed.self, from: jsonData)
                        self.cancelledReq_tableView.reloadData()
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
