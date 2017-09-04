//
//  MapViewController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 16/02/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    var places = [Place]()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configMap()
        configLocationManager()
        // Center Map
        centerUserLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Retrieve data from other view
        let search:ViewController = self.tabBarController?.viewControllers![0] as! ViewController
        places = search.places
        
        // Add annotation
        addAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        
        if status == .authorizedWhenInUse{
            map.showsUserLocation = true
            locationManager.startUpdatingLocation()
            print("yes")
        }
        else{
            map.showsUserLocation = false
            print("no")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: {
            action in
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    }
    
    // MARK: Private Methods
    
    private func configMap(){
        map.delegate = self
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
    }
    
    private func configLocationManager()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }else if(authorizationStatus == CLAuthorizationStatus.denied){
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func addAnnotations () {
        
        map.removeAnnotations(map.annotations)
        if !places.isEmpty {
            for row in places{
                
                var marker = CLLocationCoordinate2D()
                marker.latitude = Double(row.latitude)
                marker.longitude = Double(row.longitude)
                let pin = MKPointAnnotation()
                pin.title = row.principalName
                pin.subtitle = "\(row.latitude) & \(row.longitude)"
                //pin.subtitle = "(\(userlocation.coordinate.latitude),\(userlocation.coordinate.longitude))"
                pin.coordinate = marker
                map.addAnnotation(pin)
            }

        }
    }
    
    private func centerUserLocation() {
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!,longitude: longitude!), span: span)
        map.setRegion(region, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
