//
//  LibraryViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/2.
//

import UIKit
import GoogleMaps
import GooglePlaces

struct Location {
    var name: String
    var phone: String
    var latitude: Double
    var longitude: Double
    var adderass: String
}

class MapViewController: UIViewController, CLLocationManagerDelegate {


    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var normailButton: UIButton!
    @IBOutlet weak var sepcialButton: UIButton!
    private var placesClient: GMSPlacesClient!

    var locationManager = CLLocationManager()
    var locationsNormal = [GMSMarker]()
    var locationsSpecial = [GMSMarker]()

    var infoWindow = MapMarkerWindow()
    var locationMarker: GMSMarker = GMSMarker()

    var gcpKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()

        let camera = GMSCameraPosition(latitude: 47.0169, longitude: -122.336471, zoom: 12)

        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")
        self.infoWindow = loadNiB()

        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()

        getGCPKey()
        getLocation()
        getSpecialLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation] ) {

        let userLocation = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 17.0)
        mapView.camera = camera
        locationManager.stopUpdatingLocation()
    }

    func getGCPKey(){
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return }

        if let myDict = NSDictionary(contentsOfFile: path){
            self.gcpKey = myDict["GCP_KEY"] as? String ?? ""
        }

    }

    func getLocation() {

        var components = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/1ZfgSLKt-SW73SnaTXZAsslwmdJPEW3JlZMS7NxXJ-kQ/values/Hospital?")!
        let key = URLQueryItem(name: "key", value: gcpKey)
        let address = URLQueryItem(name: "majorDimension", value: "ROWS")
        components.queryItems = [key, address]
        print( " KEY = ===== = = = == = \(gcpKey)")

        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }
            guard let results = json["values"] as? [[String]] else { return }

            results.forEach { hostipal in
                guard let latitude = Double(hostipal[3]),
                      let longitude = Double(hostipal[4])
                else { return }
                let location = Location(name: hostipal[0], phone: hostipal[2], latitude: latitude, longitude: longitude, adderass: hostipal[1])
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//                marker.title = location.name
//                marker.snippet = location.phone
                marker.map = self.mapView
                marker.userData = location
                self.locationsNormal.append(marker)
            }
        }
        task.resume()
        
    }

    func getSpecialLocation() {

        var components = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/1ZfgSLKt-SW73SnaTXZAsslwmdJPEW3JlZMS7NxXJ-kQ/values/Hospital_special?")!
        let key = URLQueryItem(name: "key", value: gcpKey) // use your key
        let address = URLQueryItem(name: "majorDimension", value: "ROWS")
        components.queryItems = [key, address]

        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }
            guard let results = json["values"] as? [[String]] else { return }
            results.forEach { hostipal in
                guard let latitude = Double(hostipal[3]),
                      let longitude = Double(hostipal[4])
                else { return }
                let location = Location(name: hostipal[0], phone: hostipal[2], latitude: latitude, longitude: longitude, adderass: hostipal[1])
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//                marker.title = location.name
//                marker.snippet = location.phone
                marker.icon =  GMSMarker.markerImage(with: .yellow)
                marker.map = self.mapView
                marker.userData = location
                self.locationsSpecial.append(marker)
            }
        }
        task.resume()

    }

    func loadNiB() -> MapMarkerWindow {
        guard let infoWindow = MapMarkerWindow.instanceFromNib() as? MapMarkerWindow else { return MapMarkerWindow() }
        return infoWindow
    }

    @IBAction func showAllHostipal(_ sender: Any) {
        locationsNormal.forEach { marker in
            marker.map = mapView
        }
        locationsSpecial.forEach { marker in
            marker.map = mapView
        }
        allButton.isSelected = true
        normailButton.isSelected = false
        sepcialButton.isSelected = false

    }

    @IBAction func showNormailHostipal(_ sender: Any) {

        locationsNormal.forEach { marker in
            marker.map = mapView
        }
        locationsSpecial.forEach { marker in
            marker.map = nil
        }

        allButton.isSelected = false
        normailButton.isSelected = true
        sepcialButton.isSelected = false


    }
    @IBAction func showSpecialHostipal(_ sender: Any) {
        locationsNormal.forEach { marker in
            marker.map = nil
        }
        locationsSpecial.forEach { marker in
            marker.map = mapView
        }

        allButton.isSelected = false
        normailButton.isSelected = false
        sepcialButton.isSelected = true
    }
}

//    func performGoogleSearch(for string: String) {
//
//        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
//        let key = URLQueryItem(name: "key", value: "AIzaSyCuIEN8YUXa-OS0S5L2nOW_O__u4NfzfdY") // use your key
//        let address = URLQueryItem(name: "address", value: string)
//        components.queryItems = [key, address]
//
//        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
//            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
//                print(String(describing: response))
//                print(String(describing: error))
//                return
//            }
//
//            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
//                print("not JSON format expected")
//                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
//                return
//            }
//
//            guard let results = json["results"] as? [[String: Any]],
//                let status = json["status"] as? String,
//                status == "OK" else {
//                    print("no results")
//                    print(String(describing: json))
//                    return
//            }
//
//            DispatchQueue.main.async {
//                // now do something with the results, e.g. grab `formatted_address`:
//                let strings = results.compactMap { $0["formatted_address"] as? String }
//                print (results)
//                print (strings)
//            }
//        }
//
//        task.resume()
//    }

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

extension MapViewController: GMSMapViewDelegate, MapMarkerDelegate {

    func didTapInfoButton(data: Location) {

        if UIApplication.shared.canOpenURL(NSURL(string: "comgooglemaps-x-callback://")! as URL) {  // if phone has an app

            let orgurl = "comgooglemaps-x-callback://?saddr=&daddr=\(data.name)&directionsmode=driving"
            if let url = orgurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: url + "&x-success=sourceapp://?resume=true&x-source=BFF") {
                    print("854645464")
                    UIApplication.shared.open(url)
                }
            }

        } else {
            // Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?api=1&destination=\(data.name)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }

    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData: Location?
        if let data = marker.userData! as? Location {
            markerData = data
        }
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        let location = locationMarker.position
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.spotData = markerData
        infoWindow.delegate = self

        // Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.borderColor = UIColor.orange.cgColor
        infoWindow.linkButton.layer.cornerRadius = infoWindow.linkButton.frame.height / 2

        infoWindow.addressLabel.text = markerData?.adderass
        infoWindow.nameLabel.text = markerData?.name
        infoWindow.phoneLabel.text = markerData?.phone

        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y -=  60
        self.view.addSubview(infoWindow)
        return false
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {

        let location = locationMarker.position

        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y -=  60

    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }

}
