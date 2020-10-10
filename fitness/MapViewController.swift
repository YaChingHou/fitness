//
//  MapViewController.swift
//  fitness
//
//  Created by zoehor on 2020/9/17.
//  Copyright © 2020 zoehor. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
   
    @IBOutlet weak var mapview: GMSMapView!
   
    var locationManager = CLLocationManager()
    
    //
    var searchResultController : SearchResultsController!
    var resultsArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //initial the Map camera around the Taipei 101
        let camera = GMSCameraPosition.camera(withLatitude: 25.033204, longitude: 121.56387570000001, zoom: 12.0)
        
        mapview.camera = camera
        
        //委派給ViewController
        locationManager.delegate = self
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        //設定為最佳精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //user授權
        locationManager.requestWhenInUseAuthorization()
        //開始update位置
        locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         
        let currentLocation: CLLocation = locations[0] as CLLocation
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude

        //show the marker on the map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.map = mapview
        
        print("Current Location: \(lat), \(lon)")
        
        if let location = locations.first {
          CATransaction.begin()
          CATransaction.setValue(Int(2), forKey: kCATransactionAnimationDuration)
          mapview.animate(toLocation: location.coordinate)
          mapview.animate(toZoom: 12)
          CATransaction.commit()
        }
        
    }
    
   
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           
                   let placeClient = GMSPlacesClient()
           
           
                   placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
                      // NSError myerr = Error;
                      // print("Error @%",Error.self)
           
                      self.resultsArray.removeAll()
                       if results == nil {
                           return
                       }
           
                       for result in results! {
                           if let result = result as? GMSAutocompletePrediction {
                               self.resultsArray.append(result.attributedFullText.string)
                           }
                       }
           
                       //self.searchResultController.reloadDataWithArray(self.resultsArray)
           
                   }
           
           
           //self.resultsArray.removeAll()
           //gmsFetcher?.sourceTextHasChanged(searchText)
           
           
       }
    
    //
    @IBAction func searchWithAddress(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        
        searchController.searchBar.delegate = self
        
        
        
        self.present(searchController, animated:true, completion: nil)
        
        
    }
    
    
}
 
