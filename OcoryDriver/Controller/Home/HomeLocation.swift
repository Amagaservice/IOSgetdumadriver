//
//  HomeLocation.swift
//  OcoryDriver
//
//  Created by nile on 07/07/21.
//

import UIKit
import CoreLocation
import Alamofire
import GoogleMaps
import GooglePlaces

extension HomeViewController {
    //MARK:- set up loaction
    func setUpLocation(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //        locationManager.requestAlwaysAuthorization()
        //        locationManager.requestWhenInUseAuthorization()
        //  locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = CLActivityType.automotiveNavigation
        //       locationManager.distanceFilter = 1
        //      locationManager.headingFilter = 1
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        marker.map = nil
        addCurrentLocationMarker()
    }
    //MARK:- routing line api
    func routingLines(origin: String,destination: String){
      let googleapi =  "AIzaSyA-ks2CpJHvxyKz6TQejEjCGr2xLihH5IA"

        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleapi)"

        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let routes = JSON["routes"] as! NSArray
                    for route in routes
                    {
                        let values = route as! NSDictionary
                        
                        let routeOverviewPolyline = values["overview_polyline"] as! NSDictionary
                        let path = GMSPath.init(fromEncodedPath: routeOverviewPolyline["points"] as! String)
                        
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = .blue
                        polyline.strokeWidth = 2.0
                        polyline.map = self.mapView //where mapView is your @IBOutlet which is in GMSMapView!
                    }
                }
            case .failure(let error): break
            // error handling
                self.showAlert("GetDuma Driver", message: "\(String(describing: error.errorDescription))")

            }
        }
    }
    
    //MARK:- draw poly line google api
    func getPolylineRoute(source: String,destination: String){
        let googleapi =  "AIzaSyA-ks2CpJHvxyKz6TQejEjCGr2xLihH5IA"

        Indicator.shared.showProgressView(self.view)

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)

            let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&mode=driving&key=\(googleapi)")
        
        let task = session.dataTask(with: url!, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    Indicator.shared.hideProgressView()

                }
                else {
                    do {
                        if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{

                            guard let routes = json["routes"] as? NSArray else {
                                DispatchQueue.main.async {
                                    Indicator.shared.hideProgressView()
                                }
                                return
                            }

                            if (routes.count > 0) {
                                let overview_polyline = routes[0] as? NSDictionary
                                let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary

                                let points = dictPolyline?.object(forKey: "points") as? String

                                self.showPath(polyStr: points!)

                                DispatchQueue.main.async {
                                    Indicator.shared.hideProgressView()
                                    let lat = kPickLat.toDouble()
                                    let lon = kPickLong.toDouble()
                                    let firstCoordinates = CLLocationCoordinate2D(latitude: Double((kPickLat as NSString).doubleValue), longitude: Double((kPickLong as NSString).doubleValue))
                                    let droplat = kDropLat.toDouble()
                                    let droplon = kDropLong.toDouble()
                                    let secondCoordinates = CLLocationCoordinate2D(latitude:droplat!
                                                            , longitude:droplon!)
                                   

                                    let bounds = GMSCoordinateBounds(coordinate:  firstCoordinates, coordinate: secondCoordinates)
                                    let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 170, left: 30, bottom: 30, right: 30))
                                    self.mapView!.moveCamera(update)
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    Indicator.shared.hideProgressView()
                                }
                            }
                        }
                    }
                    catch {
                        print("error in JSONSerialization")
                        DispatchQueue.main.async {
                            Indicator.shared.hideProgressView()
                        }
                    }
                }
            })
            task.resume()
        }

    //MARK:- show path 
        func showPath(polyStr :String){
            let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = UIColor.red
            polyline.map = mapView // Your map view
        }
//    func LoadMapRoute(origin: String,destination: String)
//    {
//        let googleapi =  "AIzaSyA-ks2CpJHvxyKz6TQejEjCGr2xLihH5IA"
//
//        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleapi)"
//
//        let url = URL(string: urlString)
//        URLSession.shared.dataTask(with: url!, completionHandler:
//            {
//            (data, response, error) in
//            if(error != nil)
//            {
//                print("error")
//            }
//            else
//            {
//                do{
//                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
//                    let arrRouts = json["routes"] as! NSArray
//
//                    for  polyline in self.arrayPolyline
//                    {
//                        polyline.map = nil;
//                    }
//
//                    self.arrayPolyline.removeAll()
//
//                    let pathForRought:GMSMutablePath = GMSMutablePath()
//
//                    if (arrRouts.count == 0)
//                    {
//                        let distance:CLLocationDistance = CLLocation.init(latitude: kPickLat, longitude: kPickLong).distance(from: CLLocation.init(latitude: kDropLat, longitude: kDropLong))
//
//                        pathForRought.add(self.source)
//                        pathForRought.add(destination)
//
//                        let polyline = GMSPolyline.init(path: pathForRought)
//                        self.selectedRought = pathForRought.encodedPath()
//                        polyline.strokeWidth = 5
//                        polyline.strokeColor = UIColor.blue
//                        polyline.isTappable = true
//
//                        self.arrayPolyline.append(polyline)
//
//                        if (distance > 8000000)
//                        {
//                            polyline.geodesic = false
//                        }
//                        else
//                        {
//                            polyline.geodesic = true
//                        }
//
//                        polyline.map = self.mapView;
//                    }
//                    else
//                    {
//                        for (index, element) in arrRouts.enumerated()
//                        {
//                            let dicData:NSDictionary = element as! NSDictionary
//
//                            let routeOverviewPolyline = dicData["overview_polyline"] as! NSDictionary
//
//                            let path =  GMSPath.init(fromEncodedPath: routeOverviewPolyline["points"] as! String)
//
//                            let polyline = GMSPolyline.init(path: path)
//
//                            polyline.isTappable = true
//
//                            self.arrayPolyline.append(polyline)
//
//                            polyline.strokeWidth = 5
//
//                            if index == 0
//                            {
//                                self.selectedRought = routeOverviewPolyline["points"] as? String
//
//                                polyline.strokeColor = UIColor.blue;
//                            }
//                            else
//                            {
//                                polyline.strokeColor = UIColor.darkGray;
//                            }
//
//                            polyline.geodesic = true;
//                        }
//
//                        for po in self.arrayPolyline.reversed()
//                        {
//                            po.map = self.mapView;
//                        }
//                    }
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
//                    {
//                        let bounds:GMSCoordinateBounds = GMSCoordinateBounds.init(path: GMSPath.init(fromEncodedPath: self.selectedRought)!)
//
//                        self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
//                    }
//                }
//                catch let error as NSError
//                {
//                    print("error:\(error)")
//                }
//            }
//        }).resume()
//    }
}
//MARK:- Get User Location
extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        locManager.stopUpdatingLocation()
//        locManager.delegate = nil
        
        let location = locations.last! as CLLocation
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
        NSUSERDEFAULT.setValue("\(myLocation.latitude)", forKey: kCurrentLat)
        NSUSERDEFAULT.setValue("\(myLocation.longitude)", forKey: kCurrentLong)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            if error == nil{
                if ((placemark?.count ?? 0) > 0){
                    let placemark = placemark?.first
                    print(placemark?.locality as Any)
                  //  self.pickUpAddress_lbl.text = placemark?.subLocality ?? ""
                    
                    kCurrentLocaLatLong = "\(myLocation.latitude)" + "," + "\(myLocation.longitude)"
                    kCurrentLocaLat   = "\(myLocation.latitude)"
                    kCurrentLocaLong = "\(myLocation.longitude)"
                }
            }
        }
        if self.update == true{
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.latitude, longitude: myLocation.longitude, zoom: 15.0)
            self.mapView.camera = camera
            self.mapView.isMyLocationEnabled = false
            self.mapView.settings.myLocationButton = false
            // Creates a marker in the center of the map.
            marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let puppyGif = UIImage(named: "car")
            let imageView = UIImageView(image: puppyGif)
            imageView.frame = CGRect(x: 0, y: 0, width: 45, height: 30)
            marker = GMSMarker(position: location.coordinate)
            marker.iconView = imageView
            marker.map = mapView
            marker.rotation = locationManager.location?.course ?? 0
         //   marker.title = "Sydney"
         //   marker.snippet = "Australia"
          //  marker.map = self.mapView
            
            self.update = false
            
        }
    }
}


