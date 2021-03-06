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
    var adders: String
}

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var specialButton: UIButton!
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
        self.navigationController?.navigationBar.tintColor = UIColor.mainColor
        self.infoWindow = loadNiB()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()

        getGCPKey()
        getLocation()
        getSpecialLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButton.isSelected = true
        normalButton.isSelected = false
        specialButton.isSelected = false
        locationsNormal.forEach { marker in
            marker.map = mapView
        }
        locationsSpecial.forEach { marker in
            marker.map = mapView
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation] ) {

        let userLocation = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 17.0)
        mapView.camera = camera
        locationManager.stopUpdatingLocation()
    }

    private func getGCPKey() {

        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return }

        if let myDict = NSDictionary(contentsOfFile: path) {
            self.gcpKey = myDict["GCP_KEY"] as? String ?? ""
        }

    }

    private func getLocation() {

        var components = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/1ZfgSLKt-SW73SnaTXZAsslwmdJPEW3JlZMS7NxXJ-kQ/values/Hospital?")!
        let key = URLQueryItem(name: "key", value: gcpKey)
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

            results.forEach { hospital in
                guard let latitude = Double(hospital[3]),
                      let longitude = Double(hospital[4])
                else { return }
                let location = Location(name: hospital[0], phone: hospital[2], latitude: latitude, longitude: longitude, adders: hospital[1])
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                marker.map = self.mapView
                marker.userData = location
                self.locationsNormal.append(marker)
            }
        }
        task.resume()
        
    }

    private func getSpecialLocation() {

        var components = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/1ZfgSLKt-SW73SnaTXZAsslwmdJPEW3JlZMS7NxXJ-kQ/values/Hospital_special?")!
        let key = URLQueryItem(name: "key", value: gcpKey)
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
            results.forEach { hospital in
                guard let latitude = Double(hospital[3]),
                      let longitude = Double(hospital[4])
                else { return }
                let location = Location(name: hospital[0], phone: hospital[2], latitude: latitude, longitude: longitude, adders: hospital[1])
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                marker.icon =  GMSMarker.markerImage(with: .yellow)
                marker.map = self.mapView
                marker.userData = location
                self.locationsSpecial.append(marker)
            }
        }
        task.resume()

    }

    private func loadNiB() -> MapMarkerWindow {
        guard let infoWindow = MapMarkerWindow.instanceFromNib() as? MapMarkerWindow else { return MapMarkerWindow() }
        return infoWindow
    }

    @IBAction func showAllHospital(_ sender: Any) {
        locationsNormal.forEach { marker in
            marker.map = mapView
        }
        locationsSpecial.forEach { marker in
            marker.map = mapView
        }
        allButton.isSelected = true
        normalButton.isSelected = false
        specialButton.isSelected = false

    }

    @IBAction func showNormalHospital(_ sender: Any) {

        locationsNormal.forEach { marker in
            marker.map = mapView
        }
        locationsSpecial.forEach { marker in
            marker.map = nil
        }

        allButton.isSelected = false
        normalButton.isSelected = true
        specialButton.isSelected = false

    }
    @IBAction func showSpecialHostipal(_ sender: Any) {
        locationsNormal.forEach { marker in
            marker.map = nil
        }
        locationsSpecial.forEach { marker in
            marker.map = mapView
        }

        allButton.isSelected = false
        normalButton.isSelected = false
        specialButton.isSelected = true
    }
}

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
        infoWindow.spotData = markerData
        infoWindow.delegate = self

        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.borderColor = UIColor.mainColor.cgColor
        infoWindow.linkButton.layer.cornerRadius = infoWindow.linkButton.frame.height / 2

        infoWindow.addressLabel.text = markerData?.adders
        infoWindow.nameLabel.text = markerData?.name
        infoWindow.phoneLabel.text = markerData?.phone

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
