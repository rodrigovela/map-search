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

    
    @IBOutlet weak var map: MKMapView!
    
    let managerLocation = CLLocationManager()
    var items2:[Dictionary<String, String>] = []
    var segue: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configMap()
        /*let latitude = managerLocation.location?.coordinate.latitude
        let longitude = managerLocation.location?.coordinate.longitude
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!,longitude: longitude!), span: span)
        map.setRegion(region, animated: true)
        */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configLocationManager()
        print("# \(items2.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        map.removeAnnotations(map.annotations)
        let search:ViewController = self.tabBarController?.viewControllers![0] as! ViewController
        
        print("Will \(search.items2.count)")
        
        for row in search.items2{
            var marker = CLLocationCoordinate2D()
            marker.latitude = Double(row["lat"]!)!
            marker.longitude = Double(row["lon"]!)!
            let pin = MKPointAnnotation()
            pin.title = row["nombre"]
            //pin.subtitle = "(\(userlocation.coordinate.latitude),\(userlocation.coordinate.longitude))"
            pin.coordinate = marker
            map.addAnnotation(pin)
        }
    }
    
    func configMap(){
        map.delegate = self
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
    }
    
    func configLocationManager()
    {
        self.managerLocation.delegate = self
        self.managerLocation.desiredAccuracy = kCLLocationAccuracyBest
        //self.managerLocation.requestAlwaysAuthorization()
        //self.managerLocation.requestWhenInUseAuthorization()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            managerLocation.requestWhenInUseAuthorization()
            
        } else {
            managerLocation.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        if status == .authorizedWhenInUse{
            map.showsUserLocation = true
            managerLocation.startUpdatingLocation()
            
        }
        else{
            map.showsUserLocation = false
            print("no")
        }
        /*
        if status == .authorizedAlways{
            print("something")
            managerLocation.startUpdatingLocation()
            
        }*/
        
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
        let userlocation = locations[0] as CLLocation
        
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userlocation.coordinate.latitude,longitude: userlocation.coordinate.longitude), span: span)
        map.setRegion(region, animated: true)
        
        var marker = CLLocationCoordinate2D()
        marker.latitude = userlocation.coordinate.latitude
        marker.longitude = userlocation.coordinate.longitude
        let pin = MKPointAnnotation()
        pin.title = "User Location"
        pin.subtitle = "(\(userlocation.coordinate.latitude),\(userlocation.coordinate.longitude))"
        pin.coordinate = marker
        map.addAnnotation(pin)
        //print("hola")
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
