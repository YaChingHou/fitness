//
//  AppleMapViewController.swift
//  fitness
//
//  Created by zoehor on 2020/9/20.
//  Copyright © 2020 zoehor. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

struct CoffeeData: Decodable {
    var name: String
    var city: String
    var latitude:String
    var longitude:String
}

class AppleMapViewController: UIViewController{

    var shopName:[String] = []
    var shopCity:[String] = []
    var latstore:[String] = []
    var lonstore:[String] = []
    
    var locationManager: CLLocationManager!
    
    //@IBOutlet weak var mapView: MKMapView!
    var mapView: MKMapView!
    
    let centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "location-arrow-flat").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        configureMapView()
        enableLocationServices()
        getCoffeeData()
    }
    
    // MARK: - Selectors
    
    @objc func handleCenterLocation() {
        centerMapOnUserLocation()
        centerMapButton.alpha = 0
        
    }
    
    // MARK: - Helper Functions
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }
            
    func configureMapView() {
        mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
                
        view.addSubview(mapView)
        mapView.frame = view.frame
                
        view.addSubview(centerMapButton)
        centerMapButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44).isActive = true
        centerMapButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        centerMapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.layer.cornerRadius = 50 / 2
        centerMapButton.alpha = 0
        
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
    }
    
    func getCoffeeData() {
        let address = "https://cafenomad.tw/api/v1.2/cafes/taipei"
        if let url = URL(string: address) {
            // GET
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    
                } else if let response = response as? HTTPURLResponse,let data = data {
                    print("Status code: \(response.statusCode)")
                    let decoder = JSONDecoder()
                    if let coffeeData = try? decoder.decode([CoffeeData].self, from: data) {
                        DispatchQueue.main.async{for coffee in coffeeData {                  self.shopName.append(coffee.name)
                            self.shopCity.append(coffee.city)
                            self.latstore.append(coffee.latitude)
                            self.lonstore.append(coffee.longitude)
                            //print("\(coffee)")
                            
                            }
                            self.showThePins()
                        }
                    }
                }
            }.resume()
        } else {
            print("Invalid URL.")
        }
    }
    
    func showThePins(){
        for corrdinate in 0...latstore.count-1{
            let annotation = MKPointAnnotation()
            let lat = (self.latstore[corrdinate] as NSString).doubleValue
            let lon = (self.lonstore[corrdinate] as NSString).doubleValue
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            self.mapView.addAnnotation(annotation)
            
        }
    }
}

// MARK: - MKMapViewDelegate
extension AppleMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.centerMapButton.alpha = 1
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AppleMapViewController: CLLocationManagerDelegate {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Location auth status is NOT DETERMINED")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location auth status is RESTRICTED")
        case .denied:
            print("Location auth status is DENIED")
        case .authorizedAlways:
            print("Location auth status is AUTHORIZED ALWAYS")
        case .authorizedWhenInUse:
            print("Location auth status is AUTHORIZED WHEN IN USE")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
            
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard locationManager.location != nil else { return }
        centerMapOnUserLocation()
    }
}
